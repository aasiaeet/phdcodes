import numpy as np
import gc
from mpi4py import MPI
from sys import stdout
from scipy import sparse
from scipy import io
from scipy.sparse import linalg
from scipy.sparse import hstack

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()  # number of process = 243

n = 300000 #network size
K = 10
T = 10   # number of terms in approaximation
beta = 0.05
greedyIX = np.zeros(K)
greedyVal = np.zeros(K)

portion = n/size    # in this program, n should be a scalar multiple of size

if rank==0:
    print 'start'


######################################## preparing matrix I-P
A = io.mmread('fgraph35.mtx')


if rank==0:
    print '1'
    print np.shape(A)


outDeg = A.sum(1)
mask1 = np.ones((n,1))
mask1[outDeg.nonzero()]=0
outDeg_beta = (outDeg + mask1)/(1-beta)
P = A.multiply(sparse.csr_matrix(1/outDeg_beta))
P = P.astype('float16')


b = np.zeros((n,portion), dtype='float16')
for j in xrange(portion):
    a = rank*portion+j
    b[a,j] = 1

if rank==0:
    print '2'


comm.Barrier() ### Start stopwatch for inverse###
t_start = MPI.Wtime()

#L = sparse.eye(n) - A.multiply(sparse.csr_matrix(1/outDeg_beta))
#N = sparse.linalg.spsolve(L,b)

############################################# approximation of inverse

print "inversing"

p=P.getcol(rank*portion)
for j in xrange(1,portion):
    a = rank*portion+j
    p = hstack([p,P.getcol(a)])


bufferP = p
for t in xrange(T-1):
    p = P*p
    bufferP = bufferP + p
print "inverse done"
del P
del A
del p
gc.collect()
b = b.astype('float16')
bufferP = bufferP.astype('float32')
N = b + bufferP.toarray()
N = N.astype('float16')
##############################################




for j in xrange(portion):
    a = rank*portion+j
    N[:,j] = N[:,j]/N[a,j]



comm.Barrier()
t_diff_inv = MPI.Wtime() - t_start ### Stop stopwatch ###

print rank



v = np.zeros(n)

comm.Barrier() ### Start stopwatch ###
t_start = MPI.Wtime()

for k in xrange(K):

    if rank==0:
    print 'k'


    sendbuf = (np.sum(N,0))*(1-v[rank*portion:(rank+1)*portion])

    sendbuf_arg = sendbuf.argmax()
    sendbuf_max = sendbuf[sendbuf_arg]
    Ns = N[:,sendbuf_arg]
    Ns_s = [Ns,rank*portion+sendbuf_arg]


    comm.Barrier()


    maxval,s0 = comm.allreduce(sendbuf_max,op=MPI.MAXLOC)



    Ns_s = comm.bcast(Ns_s, root = s0)


    Ns = Ns_s[0]
    s = Ns_s[1]

    for j in xrange(portion):
        a = rank*portion+j
        if a!=s:
            N[:,j] = (N[:,j] - Ns*N[s,j])/(1-N[s,j]*Ns[a])

        else:
            N[:,j] = 0

    v = v + (1-v[s])*Ns

    comm.Barrier()

    greedyIX[k] = s+1
    greedyVal[k] = np.sum(v)

#### end of for

comm.Barrier()
t_diff = MPI.Wtime() - t_start ### Stop stopwatch ###

if rank==0:
    print 'RunTime: ', t_diff
    stdout.flush()

    print 'InvRunTime: ', t_diff_inv
    stdout.flush()

    print 'greedyIX: ', greedyIX
    stdout.flush()

    print 'greedyVal: ', greedyVal
    stdout.flush()
                                                                           