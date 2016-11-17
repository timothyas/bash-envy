# demo from fenicsproject.org for solving poisson equation

from dolfin import *
import matplotlib.pyplot as plt
import pylab as pyl

# Create mesh and define function space
mesh = UnitSquareMesh(32, 32)
V = FunctionSpace(mesh, "Lagrange", 1)

# Define Dirichlet boundary (x = 0 or x = 1)
def boundary(x):
    return x[0] < DOLFIN_EPS or x[0] > 1.0 - DOLFIN_EPS

# Define boundary condition
u0 = Function(V) #Constant(0.0)
bc = DirichletBC(V, u0, boundary)

# Define variational problem
u = TrialFunction(V)
v = TestFunction(V)
f = Expression("10*exp(-(pow(x[0] - 0.5, 2) + pow(x[1] - 0.5, 2)) / 0.02)", degree=2)
g_1 = Expression("sin(5*x[0])", degree=2)
g_2 = Expression("x[0] + x[1]",degree=2)
g_3 = Expression("x[0]*x[0]", degree=2)
g=g_3
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
# plot(res,mesh.root_node(),title='residual',interactive=True)

plt.figure()
plot(u.root_node(),title="Solution on initial mesh",interactive=True)
#plt.savefig('figures/u_0.png') #, bbox_inches='tight')

plot(u.leaf_node(),title="Solution on final mesh",interactive=True)
#pyl.savefig('figures/u_f.png', bbox_inches='tight')

plot(mesh.root_node(),title="coarsest mesh",interactive=True)
plot(mesh.leaf_node(),title="finest mesh",interactive=True)


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

