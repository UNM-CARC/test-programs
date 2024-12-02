# -------------------------------------------------------------
# Bulk Configuration
# -------------------------------------------------------------

# Set up lattice
vector_a = [1.3325, -2.30795770109, 0.0]*Angstrom
vector_b = [1.3325, 2.30795770109, 0.0]*Angstrom
vector_c = [0.0, 0.0, 4.947]*Angstrom
lattice = UnitCell(vector_a, vector_b, vector_c)

# Define elements
elements = [Zinc, Zinc]

# Define coordinates
fractional_coordinates = [[ 0.333333329801,  0.666666670199,  0.25 ],
                          [ 0.666666670199,  0.333333329801,  0.75 ]]

# Set up configuration
bulk_configuration = BulkConfiguration(
    bravais_lattice=lattice,
    elements=elements,
    fractional_coordinates=fractional_coordinates
    )

# -------------------------------------------------------------
# Calculator
# -------------------------------------------------------------
#----------------------------------------
# Basis Set
#----------------------------------------
basis_set = DFTBDirectory("cp2k/scc/")

#----------------------------------------
# Pair Potentials
#----------------------------------------
pair_potentials = DFTBDirectory("cp2k/scc/")

# List of values for the grid mesh cutoff
cutoffs = [2.5, 5, 10, 20, 30, 40, 60, 80]

# List to hold the chemical potential for each calculation.
chemical_potentials = []

# Loop over the grid mesh cutoffs
for cutoff in cutoffs:

    numerical_accuracy_parameters = NumericalAccuracyParameters(
        k_point_sampling=(7, 7, 51),
        density_mesh_cutoff=cutoff*Hartree
        )

    iteration_control_parameters = IterationControlParameters()

    calculator = SlaterKosterCalculator(
        basis_set=basis_set,
        pair_potentials=pair_potentials,
        numerical_accuracy_parameters=numerical_accuracy_parameters,
        iteration_control_parameters=iteration_control_parameters,
        )

    bulk_configuration.setCalculator(calculator)
    bulk_configuration.update()

    # -------------------------------------------------------------
    # Chemical Potential
    # -------------------------------------------------------------
    chemical_potential = ChemicalPotential(bulk_configuration)
    value = chemical_potential.evaluate().inUnitsOf(eV)
    chemical_potentials.append(value)

# Plot data.
import pylab

pylab.plot(cutoffs, chemical_potentials, 'ro-')
pylab.xlabel('Grid mesh cut-off (Ha)')
pylab.ylabel('Fermi level (eV)')

# Show the plot.
pylab.show()