import numpy as np
import matplotlib.pyplot as plt
t = np.linspace (0,1,1000)
A = 5
f0 = 5
phi = [0,90,180,270,360]
f = [1,3,5,8,10]
ph = 0
n = 0
# Y = 4/np.pi * np.sin(2 * np.pi * f0 * t + np.pi/2) +  4/(3*np.pi) * np.sin(2 * np.pi * 3 * f0 * t - np.pi/2)
Y = (4/(2*n-1) * np.pi) * np.sin (2 * np.pi * (2 * n - 1) * f0 * t - np.pi/2)

for i in range (len(phi)):
    # x = A * np.sin(2 * np.pi * f[i] * t + phi[i]*np.pi/180)
    x = (4/(2*n-1) * np.pi) * np.sin (2 * np.pi * (2 * n - 1) * f0 * t - np.pi/2 + phi[i]*np.pi/180)
    Y = Y + x
    # plt.subplot(2,2,i+1)
    plt.plot(t,x, ':')
    plt.xlabel('Time')
    plt.ylabel('Amplitude')


plt.plot(t,Y, 'r')

plt.xlabel('Time')
plt.ylabel('Amplitude')
# plt.plot(t,x)
plt.grid(True)
plt.show()


# plt.title('A = {}V,F={}')