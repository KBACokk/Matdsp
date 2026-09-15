import numpy as np
import matplotlib.pyplot as plt


print(' Пункт 1:')
A = 4
f = 0.25
sample_rat = 44100
T_periods = 3
T = 1 / f
time = T * T_periods
t = np.linspace(0, time, int(sample_rat * time), endpoint=False)
pha1 = 0.25
pha0 = 0

delta_t = pha1 / 0.4

print('Период колебания (T):', T)
print('Частота (f):', f)
print('Временной сдвиг максимума (delta_t):', delta_t)

Y = A * np.sin(2 * np.pi * f * t + pha1 * np.pi)
Y1 = A * np.sin(2 * np.pi * f * t + pha0 * np.pi)

print('\n Пункт 2 (-1, 3, 7 сек) ')
T_p2 = 4
f_p2 = 1 / T_p2

t1, t2, t3 = -1, 3, 7
phase1 = 2 * np.pi * f_p2 * t1
phase2 = 2 * np.pi * f_p2 * t2
phase3 = 2 * np.pi * f_p2 * t3

print('t = -1 с -> Фаза:', phase1, 'рад (', np.degrees(phase1), 'гр )')
print('t = 3 с  -> Фаза:', phase2, 'рад (', np.degrees(phase2), 'гр )')
print('t = 7 с  -> Фаза:', phase3, 'рад (', np.degrees(phase3)-360, 'гр )')

print('\nПункт 3')
a = 3.0
b = 4.0
z1 = complex(a, b)
z2 = complex(a, -b)

print('z1 =', z1, '-> Модуль:', np.abs(z1), 'Аргумент:', np.angle(z1))
print('z2 =', z2, '-> Модуль:', np.abs(z2), 'Аргумент:', np.angle(z2))

print('\nПункт4')
r_pol = 5.0
theta_pol = np.pi / 3

z_rect = r_pol * np.cos(theta_pol) + 1j * r_pol * np.sin(theta_pol)
print('Полярная: r =', r_pol, 'theta = pi/3')
print('Обычная форма:', z_rect.real, '+ j', z_rect.imag)

plt.figure(figsize=(10, 4))
plt.plot(t, Y, label='С фазой', color='blue')
plt.plot(t, Y1, 'r:', label='С нулевой фазой', linewidth=2)
plt.title('Графики колебаний с начальной фазой и без')
plt.xlabel('Время, с')
plt.ylabel('x(t)')
plt.grid(True)
plt.legend()
plt.show()