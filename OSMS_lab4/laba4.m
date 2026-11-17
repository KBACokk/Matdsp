clear; clc; close all;

x1 = [1 0 1 1 1];
y1 = [1 1 1 1 0];

gold1 = gen_gold(x1, y1);
fprintf('1) Последовательность Голда 1: ');
fprintf('%d', gold1); fprintf('\n\n');

s1_polar = 1 - 2*gold1;
N = length(gold1);

% --- встроенная autocorr ---
[acf, lags_acf] = autocorr(s1_polar, 'NumLags', 30);

% --- ручная циклическая автокорреляция ---
cyc_acf = zeros(1, N+1);
for shift = 0:N
    shifted = circshift(gold1, shift);
    matches = sum(gold1 == shifted);
    mismatches = N - matches;
    cyc_acf(shift+1) = (matches - mismatches) / N;
end

% --- ОБА ГРАФИКА НА ОДНОМ ПОЛОТНЕ ---
figure('Name', 'Автокорреляция кода Голда — оба метода на одном графике');

plot(lags_acf, acf, '-o', 'LineWidth', 1.8, ...
     'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410]);
hold on;

plot(0:N, cyc_acf, '-s', 'LineWidth', 2, ...
     'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980]);

grid on;
xlabel('Задержка (lag)');
ylabel('Автокорреляция');
title('Автокорреляционная функция кода Голда (Вариант №23)');
legend({'autocorr (встроенная)', 'циклическая (ручная, как в C++)'}, ...
       'Location', 'best');
ylim([-0.5 1.15]);
hold off;

%% ===== Вторая последовательность и взаимная корреляция =====
x2 = [1 1 0 0 0];
y2 = [1 1 0 0 1];
gold2 = gen_gold(x2, y2);
s2_polar = 1 - 2*gold2;

fprintf('2) Последовательность Голда 2: ');
fprintf('%d', gold2); fprintf('\n\n');

cross_zero = sum(s1_polar .* s2_polar) / N;
[r_cross, ~] = xcorr(s1_polar, s2_polar, 'normalized');

fprintf('3) Взаимная корреляция при lag=0: %.4f (макс. по xcorr: %.4f)\n\n', ...
        cross_zero, max(abs(r_cross)));

ones_count = sum(gold1 == 1);
zeros_count = sum(gold1 == 0);

fprintf('1) СБАЛАНСИРОВАННОСТЬ:\n');
fprintf('   Единиц: %d, Нулей: %d\n', ones_count, zeros_count);
if abs(ones_count - zeros_count) <= 1
    fprintf('   [OK] Свойство выполняется (разница <= 1).\n\n');
else
    fprintf('   [FAIL] Свойство НЕ выполняется.\n\n');
end

fprintf('2) ЦИКЛИЧНОСТЬ (серии одинаковых бит):\n');

gold_circ = [gold1, gold1(1)];

runs_len = [];
current_len = 1;

for i = 2:length(gold_circ)
    if gold_circ(i) == gold_circ(i-1)
        current_len = current_len + 1;
    else
        runs_len = [runs_len, current_len];
        current_len = 1;
    end
end

len1 = sum(runs_len == 1);
len2 = sum(runs_len == 2);
len3 = sum(runs_len == 3);
len4 = sum(runs_len == 4);
len5 = sum(runs_len == 5);

fprintf('   Серий длины 1: %d\n', len1);
fprintf('   Серий длины 2: %d\n', len2);
fprintf('   Серий длины 3: %d\n', len3);
fprintf('   Серий длины 4: %d\n', len4);
fprintf('   Серий длины 5: %d\n', len5);

if (len1 == 8 && len2 == 4 && len3 == 2 && len4 == 1 && len5 == 1)
    fprintf('   [OK] Распределение идеально для m-последовательности!\n\n');
else
    fprintf('   [INFO] Распределение немного отличается (нормально для кодов Голда).\n\n');
end

fprintf('3) КОРРЕЛЯЦИЯ:\n');
shifted = circshift(gold1, 1);
matches = sum(gold1 == shifted);
mismatches = N - matches;
r_auto = (matches - mismatches) / N;

fprintf('   Автокорреляция при сдвиге 1: %.4f\n', r_auto);

if abs(r_auto) < 0.5
    fprintf('   [OK] Пик только при нулевом сдвиге (боковые лепестки малы).\n');
else
    fprintf('   [FAIL] Плохая корреляция.\n');
end

function seq = gen_gold(x, y)
    seq = zeros(1, 31);
    for i = 1:31
        seq(i) = xor(x(5), y(5));
        fbX = xor(x(4), x(5));
        fbY = xor(y(2), y(5));
        x = [fbX, x(1:4)];
        y = [fbY, y(1:4)];
    end
end

fprintf('\n========== Допка ==========\n');

%m_seq = [1 0 1 1 0 1 0 1 1 1 0 0 1 0 0 1 1 0 1 0 0 0 1 1 1 0 0 1 0 1 1];
 m_seq = [1 0 0 0 0 1 0 0 1 0 1 1 0 0 1 1 1 1 1 0 0 0 1 1 0 1 0 1 1 1 0];

m_seq = m_seq(:).';

fprintf('Заданная последовательность:\n');
fprintf('%d', m_seq); fprintf('\n\n');

m_polar = 1 - 2*m_seq;

m_ones  = sum(m_seq == 1);
m_zeros = sum(m_seq == 0);
fprintf('1) Сбалансированность (m-последовательность):\n');
fprintf('   Единиц: %d, Нулей: %d\n', m_ones, m_zeros);
if abs(m_ones - m_zeros) <= 1
    fprintf('   Свойство выполняется (разница <= 1).\n\n');
else
    fprintf('   Свойство НЕ выполняется.\n\n');
end

fprintf('2) Цикличность (серии одинаковых бит, m-последовательность):\n');
m_circ = [m_seq, m_seq(1)];
runs_len_m = [];
cur = 1;
for i = 2:length(m_circ)
    if m_circ(i) == m_circ(i-1)
        cur = cur + 1;
    else
        runs_len_m = [runs_len_m, cur];
        cur = 1;
    end
end
m_len1 = sum(runs_len_m == 1);
m_len2 = sum(runs_len_m == 2);
m_len3 = sum(runs_len_m == 3);
m_len4 = sum(runs_len_m == 4);
m_len5 = sum(runs_len_m == 5);
fprintf('   Серий длины 1: %d\n', m_len1);
fprintf('   Серий длины 2: %d\n', m_len2);
fprintf('   Серий длины 3: %d\n', m_len3);
fprintf('   Серий длины 4: %d\n', m_len4);
fprintf('   Серий длины 5: %d\n', m_len5);
if (m_len1 == 8 && m_len2 == 4 && m_len3 == 2 && m_len4 == 1 && m_len5 == 1)
    fprintf('   Распределение идеально для m-последовательности!\n\n');
else
    fprintf('   Распределение отличается от идеального (заданная последовательность не является m-последовательностью).\n\n');
end

fprintf('3) Корреляция (m-последовательность):\n');
shifted_m = circshift(m_seq, 1);
matches_m = sum(m_seq == shifted_m);
mismatches_m = N - matches_m;
r_auto_m = (matches_m - mismatches_m) / N;
fprintf('   Автокорреляция при сдвиге 1: %.4f\n', r_auto_m);
if abs(r_auto_m) < 0.5
    fprintf('   Пик только при нулевом сдвиге (боковые лепестки малы).\n');
else
    fprintf('   Плохая корреляция.\n');
end

cross_m_gold = sum(m_polar .* s1_polar) / N;
[r_cross_m, ~] = xcorr(m_polar, s1_polar, 'normalized');
fprintf('   Взаимная корреляция с gold1 при lag=0: %.4f (макс. |xcorr|: %.4f)\n\n', ...
        cross_m_gold, max(abs(r_cross_m)));

% --- ДОПОЛНИТЕЛЬНЫЙ ГРАФИК ---
cyc_acf_m = zeros(1, N+1);
for shift = 0:N
    sh = circshift(m_seq, shift);
    mt = sum(m_seq == sh);
    mm = N - mt;
    cyc_acf_m(shift+1) = (mt - mm) / N;
end

cyc_xcorr_m_gold = zeros(1, N+1);
for shift = 0:N
    sh = circshift(m_seq, shift);
    mt = sum(sh == gold1);
    mm = N - mt;
    cyc_xcorr_m_gold(shift+1) = (mt - mm) / N;
end

figure('Name', 'Заданная m-последовательность: корреляция');
subplot(2,1,1);
plot(0:N, cyc_acf_m, '-o', 'LineWidth', 1.8, ...
     'Color', [0.4660 0.6740 0.1880], 'MarkerFaceColor', [0.4660 0.6740 0.1880]);
grid on;
xlabel('Задержка (lag)');
ylabel('Автокорреляция');
title('Циклическая автокорреляция заданной последовательности');
ylim([-0.5 1.15]);

subplot(2,1,2);
plot(0:N, cyc_xcorr_m_gold, '-s', 'LineWidth', 1.8, ...
     'Color', [0.4940 0.1840 0.5560], 'MarkerFaceColor', [0.4940 0.1840 0.5560]);
hold on;
plot(0:N, zeros(1,N+1), 'k--', 'LineWidth', 1);
grid on;
xlabel('Задержка (lag)');
ylabel('Взаимная корреляция');
title('Циклическая взаимная корреляция: заданная последовательность vs gold1');
ylim([-0.5 1.15]);
hold off;