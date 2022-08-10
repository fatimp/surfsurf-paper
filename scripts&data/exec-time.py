#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt

ss_cpu_2d = np.loadtxt('exec-times/surfsurf/cpu2d.dat')
ss_cpu_3d = np.loadtxt('exec-times/surfsurf/cpu3d.dat')
ss_gpu_2d = np.loadtxt('exec-times/surfsurf/gpu2d.dat')
ss_gpu_3d = np.loadtxt('exec-times/surfsurf/gpu3d.dat')

sv_cpu_2d = np.loadtxt('exec-times/surfvoid/cpu2d.dat')
sv_cpu_3d = np.loadtxt('exec-times/surfvoid/cpu3d.dat')
sv_gpu_2d = np.loadtxt('exec-times/surfvoid/gpu2d.dat')
sv_gpu_3d = np.loadtxt('exec-times/surfvoid/gpu3d.dat')

plt.figure(figsize = (10, 8), dpi = 300)
plt.rc('font', size = 18)
ax  = plt.gca()
ax2 = ax.twiny()

ax.plot(ss_cpu_2d[:,0], ss_cpu_2d[:,1], 'b.-')
ax.plot(sv_cpu_2d[:,0], sv_cpu_2d[:,1], 'g.-')
ax.plot(ss_gpu_2d[:,0], ss_gpu_2d[:,1], 'r.-')
ax.plot(sv_gpu_2d[:,0], sv_gpu_2d[:,1], 'y.-')
ax.legend(['Surface-surface 2D CPU',
           'Surface-void 2D CPU',
           'Surface-surface 2D GPU',
           'Surface-void 2D GPU'], loc = 4)

ax2.plot(ss_cpu_3d[:,0], ss_cpu_3d[:,1], 'b.--')
ax2.plot(sv_cpu_3d[:,0], sv_cpu_3d[:,1], 'g.--')
ax2.plot(ss_gpu_3d[:,0], ss_gpu_3d[:,1], 'r.--')
ax2.plot(sv_gpu_3d[:,0], sv_gpu_3d[:,1], 'y.--')
ax2.legend(['Surface-surface 3D CPU',
            'Surface-void 3D CPU',
            'Surface-surface 3D GPU',
            'Surface-void 3D GPU'], loc = 2)

plt.yscale('log')
ax.set_xlabel('Side of a square')
ax2.set_xlabel('Side of a cube')
ax.set_ylabel('Execution time, seconds')
plt.savefig('../images/exec-time.png')
