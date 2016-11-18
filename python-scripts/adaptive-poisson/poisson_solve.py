# demo from fenicsproject.org for solving poisson equation

from dolfin import *
import matplotlib.pyplot as plt
import pylab as pyl

# Create mesh and define function space
mesh = UnitSquareMesh(16, 16)
V = FunctionSpace(mesh, "Lagrange", 1)

# Define Dirichlet boundary (x = 0 or x = 1)
def boundary(x):
    return x[0] < DOLFIN_EPS or x[0] > 1.0 - DOLFIN_EPS or x[1] < DOLFIN_EPS or x[1]>1.0-DOLFIN_EPS

# Define boundary condition
u0 = Function(V) #Constant(0.0)
bc = DirichletBC(V, u0, boundary)

# Define variational problem
u = TrialFunction(V)
v = TestFunction(V)
g_0 = Expression("10*exp(-(pow(x[0] - 0.5, 2) + pow(x[1] - 0.5, 2)) / 0.02)", degree=2)
g_1 = Expression("10*exp(-(pow(x[0]-0.9, 2) + pow(x[1]-0.1, 2)) / 0.02)", degree=2)
g_2 = Expression("sin(5*x[0])", degree=2)
g_3 = Expression("x[0]*x[1]", degree=2)

f = g_3
g=Constant(0.0)
a = inner(grad(u), grad(v))*dx
L = f*v*dx + g*v*ds


# Compute solution
u = Function(V)

# Define goal function and tol
M = u*dx()
tol = 1.e-5

# Solve a = L
problem = LinearVariationalProblem(a,L,u,bc)
solver = AdaptiveLinearVariationalSolver(problem,M)
solver.parameters["error_control"]["dual_variational_solver"]["linear_solver"]="cg"
solver.parameters["error_control"]["dual_variational_solver"]["symmetric"]=True
solver.solve(tol)

solver.summary()

# res = div(grad(u.root_node())) + f
plot(f,mesh.root_node(),title='f(x) - Initial Mesh',interactive=True)
plot(f,mesh.leaf_node(),title='f(x) - Final Mesh',interactive=True)

plot(u.root_node(),title="u(x) - Initial Mesh",interactive=True)
#plt.savefig('figures/u_0.png') #, bbox_inches='tight')

plot(u.leaf_node(),title="u(x) - Final Mesh",interactive=True)
#pyl.savefig('figures/u_f.png', bbox_inches='tight')

plot(grad(u.root_node()),title='grad(u) - Initial Mesh',interactive=True)
plot(grad(u.leaf_node()),title='grad(u) - Final Mesh',interactive=True)

plot(mesh.root_node(),title="Initial",interactive=True)
plot(mesh.leaf_node(),title="Final Mesh",interactive=True)


# Compute adjoint solution
#ptrial = TrialFunction(V)
#ptest = TestFunction(V)
#a_p = inner(grad(ptrial),grad(ptest))
#Lv = g*ptest*ds
#ptrial = Function(V)
#solve(a_p == Lv, ptrial, bc)

# Save solution in VTK format
#file = File("poisson.pvd")
#file << u

