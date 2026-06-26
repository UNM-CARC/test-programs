#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_ROOT="${APP_TEST_RUN_ROOT:-$ROOT_DIR/.app-test-runs}"
RUN_ID="${APP_TEST_RUN_ID:-$(date +%Y%m%dT%H%M%S)}"
RUN_DIR="$RUN_ROOT/$RUN_ID"
LOG_DIR="$RUN_DIR/logs"
MANIFEST="$RUN_DIR/manifest.tsv"
SUBMISSIONS="$RUN_DIR/submissions.tsv"
REPORT_TSV="$RUN_DIR/report.tsv"
REPORT_MD="$RUN_DIR/report.md"
JOBEFF_LOG="$RUN_DIR/jobeff.log"

INCLUDE_PBS=0
INCLUDE_LEGACY=0
WAIT=1
QUIET=0
VERBOSE=0
POLL_SECONDS=10
SPINNER_SECONDS="${APP_TEST_SPINNER_SECONDS:-0.1}"
MAX_JOBS=0
ACTION="run"
CLUSTER="${APP_TEST_CLUSTER:-auto}"
TARGET_CLUSTER=""
PARTITION="${APP_TEST_PARTITION:-debug}"
JOBEFF=0
JOBEFF_DURATION="${APP_TEST_JOBEFF_DURATION:-10s}"
LIVE_STATUS_LINES=0
LIVE_STATUS_KEYS=""
LIVE_STATUS_VALUES=""
LIVE_STATUS_FULL=0
LIVE_STATUS_TICK=0
LIVE_SPINNER_ROWS=""
LIVE_NAME_WIDTH=68
LIVE_CHANNEL_WIDTH=42
LIVE_PATH_WIDTH=72
LIVE_STATUS_COL=$((LIVE_NAME_WIDTH + LIVE_CHANNEL_WIDTH + 3))
LIVE_VERBOSE_STATUS_COL=$((LIVE_NAME_WIDTH + LIVE_CHANNEL_WIDTH + LIVE_PATH_WIDTH + 4))

if [[ -t 1 ]]; then
    COLOR_GREEN=$'\033[32m'
    COLOR_RED=$'\033[31m'
    COLOR_YELLOW=$'\033[33m'
    COLOR_BLUE=$'\033[34m'
    COLOR_GRAY=$'\033[90m'
    COLOR_RESET=$'\033[0m'
else
    COLOR_GREEN=""
    COLOR_RED=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
    COLOR_GRAY=""
    COLOR_RESET=""
fi

usage() {
    cat <<EOF
Usage: $0 [options]

Discover, submit, and report test-program batch examples.

Options:
  --discover-only       Write the manifest and exit without submitting jobs.
  --status RUN_ID       Rebuild the report for an existing run ID.
  --include-pbs         Include PBS scripts in the manifest. They are reported
                        as unsupported unless ported to Slurm.
  --include-legacy      Include scripts targeting old clusters such as Taos,
                        Wheeler, or Xena.
  --cluster NAME        Select the cluster test suite: auto, easley, or hopper.
                        Default: auto. Set APP_TEST_CLUSTER to change it.
  --quiet               Wait for jobs without showing the live Pass/Fail table.
  --verbose             Show the Slurm script path as a second live-output column.
  --no-wait             Submit jobs, write the initial report, and return
                        without waiting for job completion.
  --poll-seconds N      Poll interval while waiting. Default: 10.
  --max-jobs N          Submit at most N runnable Slurm jobs.
  --partition NAME      Override every submitted Slurm job to this partition.
                        Default: debug. Set APP_TEST_PARTITION to change it.
  --no-partition        Do not override the partition in each Slurm script.
  --jobeff              Sample jobeff while waiting for jobs. Default: off.
  --no-jobeff           Do not sample jobeff while waiting for jobs.
  --jobeff-duration T   Duration passed to jobeff during each sample.
                        Default: 10s.
  --help                Show this help.

Outputs:
  $RUN_ROOT/<RUN_ID>/manifest.tsv
  $RUN_ROOT/<RUN_ID>/submissions.tsv
  $RUN_ROOT/<RUN_ID>/logs/
  $RUN_ROOT/<RUN_ID>/report.tsv
  $RUN_ROOT/<RUN_ID>/report.md
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --discover-only)
            ACTION="discover"
            shift
            ;;
        --status)
            ACTION="status"
            RUN_ID="${2:?missing RUN_ID for --status}"
            RUN_DIR="$RUN_ROOT/$RUN_ID"
            LOG_DIR="$RUN_DIR/logs"
            MANIFEST="$RUN_DIR/manifest.tsv"
            SUBMISSIONS="$RUN_DIR/submissions.tsv"
            REPORT_TSV="$RUN_DIR/report.tsv"
            REPORT_MD="$RUN_DIR/report.md"
            shift 2
            ;;
        --include-pbs)
            INCLUDE_PBS=1
            shift
            ;;
        --include-legacy)
            INCLUDE_LEGACY=1
            shift
            ;;
        --cluster)
            CLUSTER="${2:?missing value for --cluster}"
            shift 2
            ;;
        --wait)
            # Compatibility alias from older versions. Waiting is now the
            # default because live progress is the normal user interface.
            WAIT=1
            shift
            ;;
        --quiet)
            QUIET=1
            shift
            ;;
        --verbose)
            VERBOSE=1
            shift
            ;;
        --no-wait)
            WAIT=0
            shift
            ;;
        --poll-seconds)
            POLL_SECONDS="${2:?missing value for --poll-seconds}"
            shift 2
            ;;
        --max-jobs)
            MAX_JOBS="${2:?missing value for --max-jobs}"
            shift 2
            ;;
        --partition)
            PARTITION="${2:?missing value for --partition}"
            shift 2
            ;;
        --no-partition)
            PARTITION=""
            shift
            ;;
        --jobeff)
            JOBEFF=1
            shift
            ;;
        --no-jobeff)
            JOBEFF=0
            shift
            ;;
        --jobeff-duration)
            JOBEFF_DURATION="${2:?missing value for --jobeff-duration}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

detect_cluster() {
    local host
    host="$(hostname -s)"
    case "$host" in
        easley*|Easley*)
            echo "easley"
            ;;
        hopper*|Hopper*)
            echo "hopper"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

resolve_cluster() {
    case "$CLUSTER" in
        auto)
            TARGET_CLUSTER="$(detect_cluster)"
            if [[ "$TARGET_CLUSTER" == "unknown" ]]; then
                echo "Could not auto-detect cluster from hostname: $(hostname -s)" >&2
                echo "Use --cluster easley or --cluster hopper." >&2
                exit 2
            fi
            ;;
        easley|hopper)
            TARGET_CLUSTER="$CLUSTER"
            ;;
        *)
            echo "Unknown cluster: $CLUSTER" >&2
            echo "Expected one of: auto, easley, hopper" >&2
            exit 2
            ;;
    esac
}

resolve_cluster

is_legacy_cluster_script() {
    case "$1" in
        *taos*|*Taos*|*wheeler*|*Wheeler*|*xena*|*Xena*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

script_targets_cluster() {
    local script="$1"
    local app cluster rest

    IFS=/ read -r app cluster rest <<< "$script"
    case "$cluster" in
        Easley)
            [[ "$TARGET_CLUSTER" == "easley" ]]
            ;;
        Hopper)
            [[ "$TARGET_CLUSTER" == "hopper" ]]
            ;;
        *)
            case "$script" in
                *easley*|*Easley*|*hopper*|*Hopper*)
                    return 1
                    ;;
            esac
            return 0
            ;;
    esac
}

has_nonconforming_cluster_name() {
    local script="$1"
    local app cluster rest

    IFS=/ read -r app cluster rest <<< "$script"
    case "$cluster" in
        Easley|Hopper)
            return 1
            ;;
    esac

    case "$script" in
        *easley*|*Easley*|*hopper*|*Hopper*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

script_type() {
    case "$1" in
        *.pbs)
            echo "pbs"
            ;;
        *.slurm|*.sbatch|*/slurm-test.sh)
            echo "slurm"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

discover_scripts() {
    mkdir -p "$RUN_DIR" "$LOG_DIR"
    {
        printf "script\ttype\tstatus\treason\n"
        (
            cd "$ROOT_DIR"
            rg --files -g '*.slurm' -g '*.sbatch' -g '*.pbs' -g 'slurm-test.sh' | sort
        ) | while IFS= read -r script; do
            local type status reason
            type="$(script_type "$script")"
            status="ready"
            reason="runnable Slurm script"

            if [[ "$type" == "pbs" ]]; then
                if [[ "$INCLUDE_PBS" -eq 1 ]]; then
                    status="unsupported"
                    reason="PBS script; port to Slurm before scheduling on Easley"
                else
                    status="skipped"
                    reason="PBS script; use --include-pbs to list explicitly"
                fi
            elif [[ "$type" != "slurm" ]]; then
                status="unsupported"
                reason="unknown batch script type"
            elif ! script_targets_cluster "$script"; then
                status="skipped"
                if has_nonconforming_cluster_name "$script"; then
                    reason="cluster-specific script is not in app/Cluster/layout/slurm-test.slurm convention"
                else
                    reason="script targets a different cluster than $TARGET_CLUSTER"
                fi
            elif is_legacy_cluster_script "$script" && [[ "$INCLUDE_LEGACY" -ne 1 ]]; then
                status="skipped"
                reason="appears to target a legacy cluster; use --include-legacy to submit"
            fi

            printf "%s\t%s\t%s\t%s\n" "$script" "$type" "$status" "$reason"
        done
    } > "$MANIFEST"
}

job_state_for_status() {
    local jobid="$1"
    sacct -n -P -j "$jobid" --format=State 2>/dev/null | awk -F '|' 'NF {print $1; exit}'
}

job_exit_for_status() {
    local jobid="$1"
    sacct -n -P -j "$jobid" --format=ExitCode 2>/dev/null | awk -F '|' 'NF {print $1; exit}'
}

job_queue_state() {
    local jobid="$1"
    squeue -h -j "$jobid" -o "%T" 2>/dev/null | awk 'NF {print $1; exit}'
}

display_status_label() {
    local status="$1"
    case "$status" in
        Pass)
            printf "%sPass%s" "$COLOR_GREEN" "$COLOR_RESET"
            ;;
        Fail)
            printf "%sFail%s" "$COLOR_RED" "$COLOR_RESET"
            ;;
        Running)
            printf "%sRunning%s" "$COLOR_BLUE" "$COLOR_RESET"
            ;;
        Pending)
            printf "%sPending%s" "$COLOR_GRAY" "$COLOR_RESET"
            ;;
        Skipped|Unsupported)
            printf "%s%s%s" "$COLOR_YELLOW" "$status" "$COLOR_RESET"
            ;;
        *)
            printf "%s%s%s" "$COLOR_YELLOW" "$status" "$COLOR_RESET"
            ;;
    esac
}

test_display_status() {
    local submit_status="$1" jobid="$2"
    case "$submit_status" in
        submitted)
            if [[ -z "$jobid" || "$jobid" == "-" ]]; then
                printf "Fail"
                return
            fi

            local queue_state slurm_state exit_code
            queue_state="$(job_queue_state "$jobid")"
            if [[ -n "$queue_state" ]]; then
                case "$queue_state" in
                    RUNNING|COMPLETING|CONFIGURING)
                        printf "Running"
                        ;;
                    *)
                        printf "Pending"
                        ;;
                esac
                return
            fi

            slurm_state="$(job_state_for_status "$jobid")"
            exit_code="$(job_exit_for_status "$jobid")"
            if [[ "$slurm_state" == "COMPLETED" && "$exit_code" == "0:0" ]]; then
                printf "Pass"
            elif [[ -z "$slurm_state" ]]; then
                printf "Pending"
            elif [[ "$slurm_state" == "PENDING" ]]; then
                    printf "Pending"
            elif [[ "$slurm_state" == "RUNNING" || "$slurm_state" == "CONFIGURING" || "$slurm_state" == "COMPLETING" ]]; then
                printf "Running"
            else
                printf "Fail"
            fi
            ;;
        skipped)
            printf "Skipped"
            ;;
        unsupported)
            printf "Unsupported"
            ;;
        submit_failed)
            printf "Fail"
            ;;
        *)
            printf "Pending"
            ;;
    esac
}

status_rank() {
    case "$1" in
        Pass) printf 0 ;;
        Fail) printf 1 ;;
        Pending) printf 2 ;;
        Running) printf 3 ;;
        Skipped|Unsupported) printf 4 ;;
        *) printf 5 ;;
    esac
}

display_row_status() {
    local status="$1"
    if [[ "$status" == "Running" ]]; then
        local frames='|/-\'
        local frame="${frames:$((LIVE_STATUS_TICK % 4)):1}"
        printf "%s %s" "$(display_status_label "$status")" "$frame"
    else
        display_status_label "$status"
    fi
}

render_spinners_only() {
    [[ "$QUIET" -eq 1 ]] && return 0
    [[ -t 1 ]] || return 0
    [[ "$LIVE_STATUS_LINES" -gt 0 ]] || return 0
    [[ -n "$LIVE_SPINNER_ROWS" ]] || return 0

    local frames='|/-\'
    local frame="${frames:$((LIVE_STATUS_TICK % 4)):1}"
    local status_col="$LIVE_STATUS_COL"
    [[ "$VERBOSE" -eq 1 ]] && status_col="$LIVE_VERBOSE_STATUS_COL"

    local row up
    while IFS= read -r row; do
        [[ -n "$row" ]] || continue
        up=$((LIVE_STATUS_LINES - row + 1))
        printf '\033[s'
        [[ "$up" -gt 0 ]] && printf '\033[%dA' "$up"
        printf '\r\033[%dC%s %s\033[K' $((status_col - 1)) "$(display_status_label Running)" "$frame"
        printf '\033[u'
    done <<< "$LIVE_SPINNER_ROWS"

    LIVE_STATUS_TICK=$((LIVE_STATUS_TICK + 1))
}


script_software_channel() {
    local script="$1"
    local file="$ROOT_DIR/$script"
    local channel=""

    if [[ -f "$file" ]]; then
        channel="$(
            awk '
                {
                    module_seen = 0
                    for (i = 1; i <= NF; i++) {
                        if ($i == "module") {
                            module_seen = 1
                        } else if (module_seen && $i == "load") {
                            for (j = i + 1; j <= NF; j++) {
                                if ($j ~ /^#|^;;$/) {
                                    break
                                }
                                if ($j !~ /^-/) {
                                    if (out != "") {
                                        out = out ", "
                                    }
                                    out = out $j
                                }
                            }
                            module_seen = 0
                        }
                    }
                }
                END {print out}
            ' "$file"
        )"
    fi

    if [[ -n "$channel" ]]; then
        printf '%s' "$channel"
        return 0
    fi

    case "$script" in
        openmm/*/single-node/slurm-test.slurm)
            printf 'spack openmm/8.1.1'
            ;;
        *)
            printf 'PATH/direct'
            ;;
    esac
}

script_display_name() {
    local script="$1"
    local app cluster rest layout detail

    IFS=/ read -r app cluster rest <<< "$script"
    rest="${script#${app}/${cluster}/}"
    rest="${rest%/slurm-test.slurm}"
    rest="${rest%/slurm-test.sh}"
    [[ "$rest" == "slurm-test.slurm" || "$rest" == "slurm-test.sh" ]] && rest=""
    if [[ "$rest" == *.slurm && "$rest" != */* ]]; then
        rest="${rest%.slurm}"
    fi

    if [[ "$rest" == "$script" || -z "$rest" ]]; then
        layout="default"
        detail=""
    else
        layout="${rest%%/*}"
        if [[ "$layout" == "$rest" ]]; then
            detail=""
        else
            detail="${rest#*/}"
        fi
    fi

    case "$layout" in
        single-node) layout="single-node" ;;
        multi-node) layout="multi-node" ;;
        gpu) layout="gpu" ;;
        *) layout="$layout" ;;
    esac

    if [[ "$app" == "gaussian" ]]; then
        case "$detail" in
            gaussian16_linda)
                detail=""
                ;;
            gaussian16_linda_*)
                detail="${detail#gaussian16_linda_}"
                ;;
            gaussian16_serial)
                detail=""
                ;;
            gaussian16_*)
                detail="${detail#gaussian16_}"
                ;;
        esac
    fi

    if [[ -z "$detail" ]]; then
        case "$script" in
            Nextflow/*/single-node/slurm-test.slurm) detail="pi workflow" ;;
            Orca_MPI/*/slurm-test.slurm) detail="caffeine" ;;
            R/*/single-node/slurm-test.slurm) detail="pi estimate" ;;
            alphafold3/*/gpu/slurm-test.slurm) detail="test protein" ;;
            beast2/*/single-node/slurm-test.slurm) detail="bitflip" ;;
            bowtie/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            bowtie2/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            bwa/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            charm++/*/multi-node/slurm-test.slurm) detail="hello" ;;
            fastqc/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            fastx-toolkit/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            gatk/*/single-node/slurm-test.slurm) detail="toy VCF" ;;
            fftw/*/single-node/slurm-test.slurm) detail="1D DFT" ;;
            hdf5/*/single-node/slurm-test.slurm) detail="dataset I/O" ;;
            netcdf-c/*/single-node/slurm-test.slurm) detail="variable I/O" ;;
            gsl/*/single-node/slurm-test.slurm) detail="stats+bessel" ;;
            openblas/*/single-node/slurm-test.slurm) detail="dgemm+dgesv" ;;
            intel-oneapi-mkl/*/single-node/slurm-test.slurm) detail="dgemm+dgesv" ;;
            boost/*/single-node/slurm-test.slurm) detail="headers+container" ;;
            eigen/*/single-node/slurm-test.slurm) detail="matrix solve" ;;
            zlib-ng/*/single-node/slurm-test.slurm) detail="compress roundtrip" ;;
            netlib-scalapack/*/multi-node/slurm-test.slurm) detail="BLACS descriptor" ;;
            gaussian/*/multi-node/gaussian16_linda/slurm-test.slurm) detail="HCl" ;;
            gaussian/*/single-node/gaussian16_serial/slurm-test.slurm) detail="HCl" ;;
            hifiasm/*/single-node/slurm-test.slurm) detail="toy HiFi reads" ;;
            hpcg/*/multi-node/slurm-test.slurm) detail="hpcg.dat" ;;
            hpctoolkit/*/multi-node/slurm-test.slurm) detail="hello" ;;
            hpl/*/multi-node/slurm-test.slurm) detail="HPL.dat" ;;
            ior/*/multi-node/slurm-test.slurm) detail="4 MiB file" ;;
            julia/*/single-node/slurm-test.slurm) detail="pi estimate" ;;
            lammps/*/multi-node/slurm-test.slurm) detail="LJ fluid" ;;
            lammps/*/single-node/slurm-test.slurm) detail="LJ fluid" ;;
            mafft/*/single-node/slurm-test.slurm) detail="3 seq FASTA" ;;
            matlab/*/single-node/slurm-test.slurm) detail="pi estimate" ;;
            minimap2/*/single-node/slurm-test.slurm) detail="toy ref/query" ;;
            muscle/*/single-node/slurm-test.slurm) detail="3 seq FASTA" ;;
            namd/*/multi-node/slurm-test.slurm) detail="ubiquitin" ;;
            namd/*/single-node/slurm-test.slurm) detail="ubiquitin" ;;
            openmpi/*/multi-node/slurm-test.slurm) detail="prime sieve" ;;
            openmm/*/single-node/slurm-test.slurm) detail="harmonic bond" ;;
            openmpi/*/multi-node/mpihello/slurm-test.slurm) detail="mpihello" ;;
            parallel/*/single-node/slurm-test.slurm) detail="sha256 tasks" ;;
            paraview/*/single-node/slurm-test.slurm) detail="sphere" ;;
            petsc/*/multi-node/slurm-test.slurm) detail="PETSc smoke" ;;
            picard/*/single-node/slurm-test.slurm) detail="chr1 reference" ;;
            plink-ng/*/single-node/slurm-test.slurm) detail="toy cohort" ;;
            rsem/*/single-node/slurm-test.slurm) detail="toy transcripts" ;;
            seqkit/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            seqtk/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            snakemake/*/single-node/slurm-test.slurm) detail="pi workflow" ;;
            spark/*/single-node/slurm-test.slurm) detail="word count" ;;
            stacks/*/single-node/slurm-test.slurm) detail="sample FASTQ" ;;
            tau/*/multi-node/slurm-test.slurm) detail="hello" ;;
            trimmomatic/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            upcxx/*/multi-node/slurm-test.slurm) detail="hello" ;;
            usearch/*/single-node/slurm-test.slurm) detail="toy FASTQ" ;;
            vasp/*/NaCl_charges/slurm-test.slurm) detail="NaCl" ;;
            vcftools/*/single-node/slurm-test.slurm) detail="toy VCF" ;;
        esac
    fi

    if [[ -n "$detail" ]]; then
        detail="${detail//\// -> }"
        printf '%s -> %s -> %s' "$app" "$layout" "$detail"
    else
        printf '%s -> %s' "$app" "$layout"
    fi
}

summary_bar() {
    local total="$1" pass="$2" fail="$3" running="$4" pending="$5" skipped="$6" unsupported="$7" other="$8"
    local width=30
    local done_count=$((pass + fail + skipped + unsupported))
    local filled=0 empty bar pct

    if [[ "$total" -gt 0 ]]; then
        filled=$((done_count * width / total))
        pct=$((done_count * 100 / total))
    else
        pct=100
    fi
    empty=$((width - filled))
    bar="$(printf '%*s' "$filled" '' | tr ' ' '#')"
    bar+="$(printf '%*s' "$empty" '' | tr ' ' '-')"

    printf '[%s] %3d%%  %d/%d  %sPass:%d%s  %sFail:%d%s  %sRunning:%d%s  %sPending:%d%s  %sSkipped:%d%s' \
        "$bar" "$pct" "$done_count" "$total" \
        "$COLOR_GREEN" "$pass" "$COLOR_RESET" \
        "$COLOR_RED" "$fail" "$COLOR_RESET" \
        "$COLOR_BLUE" "$running" "$COLOR_RESET" \
        "$COLOR_GRAY" "$pending" "$COLOR_RESET" \
        "$COLOR_YELLOW" "$skipped" "$COLOR_RESET"
    [[ "$unsupported" -gt 0 ]] && printf '  %sUnsupported:%d%s' "$COLOR_YELLOW" "$unsupported" "$COLOR_RESET"
    [[ "$other" -gt 0 ]] && printf '  Other:%d' "$other"
    return 0
}

render_test_status() {
    local full="${1:-0}"
    [[ "$QUIET" -eq 1 ]] && return 0
    [[ -f "$SUBMISSIONS" ]] || return 0

    local total=0 pass=0 fail=0 running=0 pending=0 skipped=0 unsupported=0 other=0
    local changed_rows=()
    local sorted_rows=()
    local script submit_status jobid note status prior key value rank row_label row_name row_channel
    local new_values=$'\n'

    while IFS=$'\t' read -r script submit_status jobid note; do
        [[ "$script" == "script" ]] && continue
        if [[ "$submit_status" == "skipped" && ( "$note" == "script targets a different cluster than "* || "$note" == "appears to target a legacy cluster; use --include-legacy to submit" ) ]]; then
            continue
        fi
        status="$(test_display_status "$submit_status" "$jobid")"
        total=$((total + 1))
        case "$status" in
            Pass) pass=$((pass + 1)) ;;
            Fail) fail=$((fail + 1)) ;;
            Running) running=$((running + 1)) ;;
            Pending) pending=$((pending + 1)) ;;
            Skipped) skipped=$((skipped + 1)) ;;
            Unsupported) unsupported=$((unsupported + 1)) ;;
            *) other=$((other + 1)) ;;
        esac

        key="$script"
        value="$status"
        new_values+="$key"$'\t'"$value"$'\n'

        prior="$(awk -F '\t' -v k="$key" '$1 == k {print $2; exit}' <<< "$LIVE_STATUS_VALUES")"
        if [[ -z "$prior" || "$prior" != "$value" ]]; then
            rank="$(status_rank "$status")"
            changed_rows+=("$rank"$'\t'"$script"$'\t'"$status")
        fi

        if [[ "$submit_status" != "skipped" ]]; then
            rank="$(status_rank "$status")"
            row_label="$(display_row_status "$status")"
            row_name="$(script_display_name "$script")"
            row_channel="$(script_software_channel "$script")"
            sorted_rows+=("$rank"$'\t'"$row_name"$'\t'"$row_channel"$'\t'"$script"$'\t'"$status"$'\t'"$row_label")
        fi
    done < "$SUBMISSIONS"

    local summary
    summary="$(summary_bar "$total" "$pass" "$fail" "$running" "$pending" "$skipped" "$unsupported" "$other")"

    local max_rows=18
    local output_lines=()

    local spinner_rows=""
    local row_name row_channel row_script row_status row_display
    while IFS=$'\t' read -r _ row_name row_channel row_script row_status row_display; do
        [[ -n "$row_name" ]] || continue
        if [[ "$row_status" == "Running" ]]; then
            spinner_rows+="$(( ${#output_lines[@]} + 1 ))"$'\n'
        fi
        if [[ "$VERBOSE" -eq 1 ]]; then
            output_lines+=("$(printf '%-*.*s %-*.*s %-*.*s %s' "$LIVE_NAME_WIDTH" "$LIVE_NAME_WIDTH" "$row_name" "$LIVE_CHANNEL_WIDTH" "$LIVE_CHANNEL_WIDTH" "$row_channel" "$LIVE_PATH_WIDTH" "$LIVE_PATH_WIDTH" "$row_script" "$row_display")")
        else
            output_lines+=("$(printf '%-*.*s %-*.*s %s' "$LIVE_NAME_WIDTH" "$LIVE_NAME_WIDTH" "$row_name" "$LIVE_CHANNEL_WIDTH" "$LIVE_CHANNEL_WIDTH" "$row_channel" "$row_display")")
        fi
    done < <(printf '%s\n' "${sorted_rows[@]}" | sort -t $'\t' -k1,1n -k2,2)
    output_lines+=("$summary")

    if [[ -t 1 ]]; then
        if [[ "$LIVE_STATUS_LINES" -gt 0 ]]; then
            printf "\033[%dA" "$LIVE_STATUS_LINES"
        fi
        local line
        for line in "${output_lines[@]}"; do
            printf "\r\033[2K%s\n" "$line"
        done
        if [[ "$LIVE_STATUS_LINES" -gt "${#output_lines[@]}" ]]; then
            local extra
            for ((extra=${#output_lines[@]}; extra<LIVE_STATUS_LINES; extra++)); do
                printf "\r\033[2K\n"
            done
            printf "\033[%dA" $((LIVE_STATUS_LINES - ${#output_lines[@]}))
        fi
        LIVE_STATUS_LINES="${#output_lines[@]}"
        LIVE_SPINNER_ROWS="$spinner_rows"
    else
        if [[ "$full" -eq 1 ]]; then
            local line
            for line in "${output_lines[@]}"; do
                printf '%s\n' "$line"
            done
        elif [[ "$LIVE_STATUS_LINES" -eq 0 ]]; then
            printf '%s\n' "$summary"
        elif [[ "${#changed_rows[@]}" -gt 0 ]]; then
            local row_script row_status shown=0
            while IFS=$'\t' read -r _ row_script row_status; do
                [[ -n "$row_script" ]] || continue
                if [[ "$VERBOSE" -eq 1 ]]; then
                    printf '%-*.*s %-*.*s %-*.*s %s\n' "$LIVE_NAME_WIDTH" "$LIVE_NAME_WIDTH" "$(script_display_name "$row_script")" "$LIVE_CHANNEL_WIDTH" "$LIVE_CHANNEL_WIDTH" "$(script_software_channel "$row_script")" "$LIVE_PATH_WIDTH" "$LIVE_PATH_WIDTH" "$row_script" "$row_status"
                else
                    printf '%-*.*s %-*.*s %s\n' "$LIVE_NAME_WIDTH" "$LIVE_NAME_WIDTH" "$(script_display_name "$row_script")" "$LIVE_CHANNEL_WIDTH" "$LIVE_CHANNEL_WIDTH" "$(script_software_channel "$row_script")" "$row_status"
                fi
                shown=$((shown + 1))
                [[ "$shown" -ge "$max_rows" ]] && break
            done < <(printf '%s\n' "${changed_rows[@]}" | sort -t $'\t' -k1,1n -k2,2)
            if [[ "${#changed_rows[@]}" -gt "$max_rows" ]]; then
                printf '... %s more changed rows\n' "$((${#changed_rows[@]} - max_rows))"
            fi
        fi
        LIVE_STATUS_LINES=1
    fi

    LIVE_STATUS_VALUES="$new_values"
    LIVE_STATUS_TICK=$((LIVE_STATUS_TICK + 1))
}
submitted_job_ids() {
    awk -F '	' 'NR > 1 && $2 == "submitted" && $3 != "" && $3 != "-" {print $3}' "$SUBMISSIONS"
}

active_jobs_remain() {
    local jobid queue_state
    while IFS= read -r jobid; do
        queue_state="$(job_queue_state "$jobid")"
        if [[ -n "$queue_state" ]]; then
            return 0
        fi
    done < <(submitted_job_ids)
    return 1
}

wait_for_jobs() {
    render_test_status
    if ! submitted_job_ids | grep -q .; then
        return 0
    fi

    while active_jobs_remain; do
        if [[ "$JOBEFF" -eq 1 && -x /projects/systems/scripts/jobeff ]]; then
            {
                echo "=== $(date -Is) ==="
                /projects/systems/scripts/jobeff --me --groupby job --duration "$JOBEFF_DURATION" --poll_interval 5s || true
                echo
            } >> "$JOBEFF_LOG"
        fi
        local slept=0
        while awk -v slept="$slept" -v poll="$POLL_SECONDS" 'BEGIN {exit !(slept < poll)}'; do
            sleep "$SPINNER_SECONDS"
            slept="$(awk -v slept="$slept" -v step="$SPINNER_SECONDS" 'BEGIN {printf "%.3f", slept + step}')"
            render_spinners_only
        done
        render_test_status
    done
    render_test_status 1
}
submit_jobs() {
    mkdir -p "$RUN_DIR" "$LOG_DIR"
    printf "script\tstatus\tjobid\tnote\n" > "$SUBMISSIONS"

    local submitted=0
    while IFS=$'\t' read -r script type status reason; do
        [[ "$script" == "script" ]] && continue

        if [[ "$status" != "ready" ]]; then
            printf "%s\t%s\t-\t%s\n" "$script" "$status" "$reason" >> "$SUBMISSIONS"
            continue
        fi

        if [[ "$MAX_JOBS" -gt 0 && "$submitted" -ge "$MAX_JOBS" ]]; then
            printf "%s\tskipped\t\tmax job limit reached\n" "$script" >> "$SUBMISSIONS"
            continue
        fi

        local dir base output error sbatch_output rc
        dir="$(dirname "$script")"
        base="$(basename "$script")"
        output="$LOG_DIR/%x-%j.out"
        error="$LOG_DIR/%x-%j.err"

        set +e
        if [[ -n "$PARTITION" ]]; then
            sbatch_output="$(
                cd "$ROOT_DIR/$dir" && sbatch --parsable --partition="$PARTITION" --output="$output" --error="$error" "$base" 2>&1
            )"
        else
            sbatch_output="$(
                cd "$ROOT_DIR/$dir" && sbatch --parsable --output="$output" --error="$error" "$base" 2>&1
            )"
        fi
        rc=$?
        set -e

        if [[ "$rc" -eq 0 ]]; then
            local jobid note
            # Some clusters print informational sbatch warnings before the
            # parsable job id.  The numeric id is required by this test runner;
            # any warning text is reporting metadata, not part of running the
            # application example itself.
            jobid="$(printf "%s\n" "$sbatch_output" | awk '/^[0-9]+([.;][A-Za-z0-9_.-]+)?$/ {id=$0} END {print id}')"
            note="$(printf "%s\n" "$sbatch_output" | awk '!/^[0-9]+([.;][A-Za-z0-9_.-]+)?$/ {if (out) out=out " | " $0; else out=$0} END {print out}')"
            [[ -z "$note" ]] && note="-"

            if [[ -n "$jobid" ]]; then
                printf "%s\tsubmitted\t%s\t%s\n" "$script" "$jobid" "$note" >> "$SUBMISSIONS"
                submitted=$((submitted + 1))
            else
                sbatch_output="${sbatch_output//$'\n'/ | }"
                printf "%s\tsubmit_failed\t-\t%s\n" "$script" "$sbatch_output" >> "$SUBMISSIONS"
            fi
        else
            sbatch_output="${sbatch_output//$'\n'/ | }"
            printf "%s\tsubmit_failed\t-\t%s\n" "$script" "$sbatch_output" >> "$SUBMISSIONS"
        fi
    done < "$MANIFEST"
}

job_field() {
    local jobid="$1" field="$2"
    sacct -n -P -j "$jobid" --format="$field" 2>/dev/null | awk -F '|' 'NF {print $1; exit}'
}

scan_logs() {
    local jobid="$1"
    local hits
    hits="$(grep -Eil '(^|[^A-Za-z])(error|fatal|traceback|segmentation fault|cannot|failed)([^A-Za-z]|$)' "$LOG_DIR"/*-"$jobid".out "$LOG_DIR"/*-"$jobid".err 2>/dev/null | xargs -r -n1 basename | paste -sd, -)"
    printf "%s" "$hits"
}

write_report() {
    [[ -f "$SUBMISSIONS" ]] || {
        echo "Missing submissions file: $SUBMISSIONS" >&2
        exit 1
    }

    {
        printf "script\tsoftware_channel\tstatus\tjobid\tslurm_state\texit_code\telapsed\talloc_nodes\talloc_cpus\tmax_rss\tlog_notes\tnote\n"
        while IFS=$'\t' read -r script submit_status jobid note; do
            [[ "$script" == "script" ]] && continue

            local status slurm_state exit_code elapsed nodes cpus rss log_notes
            status="$submit_status"
            slurm_state=""
            exit_code=""
            elapsed=""
            nodes=""
            cpus=""
            rss=""
            log_notes=""

            if [[ "$submit_status" == "submitted" && -n "$jobid" && "$jobid" != "-" ]]; then
                slurm_state="$(job_field "$jobid" "State")"
                exit_code="$(job_field "$jobid" "ExitCode")"
                elapsed="$(job_field "$jobid" "Elapsed")"
                nodes="$(job_field "$jobid" "AllocNodes")"
                cpus="$(job_field "$jobid" "AllocCPUS")"
                rss="$(sacct -n -P -j "$jobid" --format=MaxRSS 2>/dev/null | awk -F '|' 'NF && $1 != "" {print $1; exit}')"
                log_notes="$(scan_logs "$jobid")"

                if [[ "$slurm_state" == "COMPLETED" && "$exit_code" == "0:0" ]]; then
                    status="pass"
                    [[ -n "$log_notes" ]] && status="pass_with_log_warnings"
                elif [[ -z "$slurm_state" ]]; then
                    status="unknown"
                    note="job not visible in sacct yet"
                elif [[ "$slurm_state" == "PENDING" || "$slurm_state" == "RUNNING" || "$slurm_state" == "CONFIGURING" || "$slurm_state" == "COMPLETING" ]]; then
                    status="running"
                else
                    status="fail"
                fi
            fi

            printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
                "$script" "$(script_software_channel "$script")" "$status" "$jobid" "$slurm_state" "$exit_code" \
                "$elapsed" "$nodes" "$cpus" "$rss" "$log_notes" "$note"
        done < "$SUBMISSIONS"
    } > "$REPORT_TSV"

    {
        echo "# Application Test Report"
        echo
        echo "- Run ID: \`$RUN_ID\`"
        echo "- Root: \`$ROOT_DIR\`"
        echo "- Cluster: \`$TARGET_CLUSTER\`"
        echo "- Partition override: \`${PARTITION:-none}\`"
        echo "- jobeff log: \`$JOBEFF_LOG\`"
        echo "- Generated: \`$(date -Is)\`"
        echo
        echo "| Status | Count |"
        echo "|---|---:|"
        awk -F '\t' 'NR > 1 {count[$3]++} END {for (s in count) print s "\t" count[s]}' "$REPORT_TSV" \
            | sort \
            | while IFS=$'\t' read -r status count; do
                printf "| %s | %s |\n" "$status" "$count"
            done
        echo
        echo "| Script | Software Channel | Status | JobID | Slurm State | Exit | Elapsed | Notes |"
        echo "|---|---|---|---:|---|---|---|---|"
        awk -F '\t' 'NR > 1 {printf "| `%s` | %s | %s | %s | %s | %s | %s | %s%s%s |\n", $1, $2, $3, $4, $5, $6, $7, $11, ($11 && $12 ? "; " : ""), $12}' "$REPORT_TSV"
    } > "$REPORT_MD"
}

case "$ACTION" in
    discover)
        discover_scripts
        echo "Wrote manifest: $MANIFEST"
        ;;
    status)
        write_report
        echo "Wrote report: $REPORT_MD"
        ;;
    run)
        discover_scripts
        submit_jobs
        if [[ "$WAIT" -eq 1 ]]; then
            wait_for_jobs
        fi
        write_report
        echo "Run ID: $RUN_ID"
        echo "Manifest: $MANIFEST"
        echo "Submissions: $SUBMISSIONS"
        echo "Report: $REPORT_MD"
        ;;
esac
