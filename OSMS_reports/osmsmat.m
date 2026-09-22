clear; clc; close all;
fprintf('      Первая лаба (выжить бы)\n');
f = 13.0; 
T_total = 1.0;
% Пункт 2: Определение максимальной частоты аналитически
f1 = f;
f2 = 5 * f;
f_max = max(f1, f2);
fprintf('[Пункт 2] Частоты гармоник: f1 = %.1f Гц, f2 = %.1f Гц => f_max = %.1f Гц\n', f1, f2, f_max);
% Пункт 3: Минимальная частота дискретизации по Котельникову (fs_base = 130 Гц)
fs_base = 140.0; 
fprintf('[Пункт 3] Частота дискретизации: fs_base = %.1f Гц (выбрана выше Котельникова для видимости пиков)\n', fs_base);
% Пункт 4: Дискретизация на 1 секунду
N_base = int32(fs_base * T_total);
t_d = (0:double(N_base)-1) / fs_base;
y_d = sin(2 * pi * f * t_d) + sin(10 * pi * f * t_d);
fprintf('[Пункт 4] Число отсчетов за 1 с: N = %d семплов\n', N_base);
% Пункт 5: Объем памяти для базовой частоты
mem_freq_base = double(N_base) * 8;
fprintf('[Пункт 5] Память (fs = %.0f Гц): %d байт\n', fs_base, mem_freq_base);
% Пункт 7: Увеличение частоты в 4 раза
fs_high = fs_base * 4;
N_high = int64(fs_high * T_total);
t_dh = (0:double(N_high)-1) / fs_high;
y_dh = sin(2 * pi * f * t_dh) + sin(10 * pi * f * t_dh);
mem_total_high = double(N_high) * 8;
fprintf('[Пункт 7] Память (fs = %.0f Гц): ИТОГО = %d байт (увеличение ровно в 4 раза)\n\n', fs_high, mem_total_high);
mainFig = figure('Name', 'Лабораторная работа №1: Все этапы анализа', 'Position', [50, 50, 1300, 850]);
tabGroup = uitabgroup(mainFig);


tab1 = uitab(tabGroup, 'Title', 'Пункты 1, 5: Сигнал и Спектр');
t_smooth = linspace(0, T_total, 2000);
y_smooth = sin(2 * pi * f * t_smooth) + sin(10 * pi * f * t_smooth);
% График 1: Непрерывный сигнал (Пункт 1)

subplot(2, 1, 1, 'Parent', tab1);
plot(t_smooth, y_smooth, 'g-', 'LineWidth', 1.5);
grid on; xlabel('Time, c'); ylabel('Amplitude');
title('Пункт 1: Непрерывный полигармонический сигнал y(t) (Вариант 23: f = 13 Гц)');
legend('y(t)', 'Location', 'NorthEast');
% График 2: Амплитудный спектр оцифрованного сигнала (Пункт 5)
N_b_double = double(N_base);
Y_synth = zeros(1, N_b_double);
for k = 0:N_b_double-1
    sum_val = 0;
    for n = 0:N_b_double-1
        sum_val = sum_val + y_d(n+1) * exp(-1j * 2 * pi * k * n / N_b_double);
    end
    Y_synth(k+1) = sum_val;
end
amp_synth = abs(Y_synth(1:double(N_base)/2+1)) / (double(N_base)/2);
freqs_synth = (0:(double(N_base)/2 )) * (fs_base / double(N_base));
subplot(2, 1, 2, 'Parent', tab1);
stem(freqs_synth, amp_synth, 'g', 'LineWidth', 1.2, 'MarkerFaceColor', 'b');
grid on; xlabel('Частота, Гц'); ylabel('Норм. амплитуда');
title('Пункт 5: Амплитудный спектр оцифрованного сигнала (13 Гц и 65 Гц)');
xlim([0, 70]);


tab2 = uitab(tabGroup, 'Title', 'Пункты 6, 7: Восстановление');
% График 1: Восстановление по Т. Котельникова (Пункт 6)
subplot(2, 1, 1, 'Parent', tab2);
plot(t_smooth, y_smooth, 'b-', 'LineWidth', 1, 'DisplayName', 'Оригинал y(t)');
hold on;
plot(t_d, y_d, 'r--o', 'LineWidth', 1, 'MarkerSize', 4, 'DisplayName', 'Восстановленный (fs = 130 Гц)');
grid on; xlabel('Time, c'); ylabel('Amplitude');
title(sprintf('Пункт 6: Восстановление сигнала по Т. Котельникова (fs = %.1f Гц, N = %d)', fs_base, N_base));
legend('Location', 'NorthEast'); hold off;
% График 2: Восстановление при 4-кратной частоте (Пункт 7)
subplot(2, 1, 2, 'Parent', tab2);
plot(t_smooth, y_smooth, 'b-', 'LineWidth', 1, 'DisplayName', 'Оригинал y(t)');
hold on;
plot(t_dh, y_dh, 'r--o', 'LineWidth', 0.8, 'MarkerSize', 2, 'DisplayName', 'Восстановленный (fs = 520 Гц)');
grid on; xlabel('Time, c'); ylabel('Amplitude');
title(sprintf('Пункт 7: Восстановление сигнала при 4-кратной частоте (fs = %.1f Гц, N = %d отсчетов)', fs_high, N_high));
legend('Location', 'NorthEast'); hold off;


tab3 = uitab(tabGroup, 'Title', 'Пункты 9-12: Анализ голоса и децимация');
[y_voice, Fs_voice] = audioread('voices.wav');
num_elements_total = numel(y_voice);
num_frames = size(y_voice, 1);
duration_voice = num_frames / Fs_voice;
% Пункт 10: Расчет частоты дискретизации
Fs_calc_channel = num_frames / duration_voice;
Fs_calc_total = num_elements_total / duration_voice;
fprintf('[Пункт 10] Анализ аудиофайла voices.wav:\n');
fprintf('           - Частота из заголовка: %d Гц\n', Fs_voice);
fprintf('           - Длительность записи: %.4f с\n', duration_voice);
fprintf('           - Число отсчетов на канал: %d\n', num_frames);
fprintf('           - Общее число элементов (стерео): %d\n', num_elements_total);
fprintf('           - Рассчитанная частота на канал: %.1f Гц (100%% совпадение)\n', Fs_calc_channel);
fprintf('           - Суммарный поток отсчетов 2 каналов: %.1f Гц (2 * Fs)\n\n', Fs_calc_total);
if size(y_voice, 2) > 1
    y_voice_mono = y_voice(:, 1);
else
    y_voice_mono = y_voice;
end
% Пункт 11: Децимация 
dec_factor = 10;
y_voice_dec = downsample(y_voice_mono, dec_factor);
Fs_new = Fs_voice / dec_factor;
fprintf('[Пункт 11] Прореживание в %d раз: новая частота Fs_new = %d Гц (f_Nyquist = %.1f Гц)\n\n', dec_factor, Fs_new, Fs_new / 2);

zvuk = audioplayer(y_voice_dec, Fs_new);
play(zvuk);

% Пункт 12: Корректное вычисление спектров
n_orig = 1024;
n_dec = round(n_orig / dec_factor); 
frag_orig = y_voice_mono(1:n_orig);

Y_orig_v = zeros(1, n_orig);
for k = 0:n_orig-1
    sum_val = 0;
    for n = 0:n_orig-1
        sum_val = sum_val + frag_orig(n+1) * exp(-1j * 2 * pi * k * n / n_orig);
    end
    Y_orig_v(k+1) = sum_val;
end

freqs_orig = (0:(n_orig/2 - 1)) * (Fs_voice / n_orig);
amp_orig_v = abs(Y_orig_v(1:n_orig/2));

frag_dec = y_voice_dec(1:min(1024, length(y_voice_dec)));
n_dec_full = length(frag_dec);

Y_dec_full = zeros(1, n_dec_full);
for k = 0:n_dec_full-1
    sum_val = 0;
    for n = 0:n_dec_full-1
        sum_val = sum_val + frag_dec(n+1) * exp(-1j * 2 * pi * k * n / n_dec_full);
    end
    Y_dec_full(k+1) = sum_val;
end

freqs_dec_full = (0:(n_dec_full/2 - 1)) * (Fs_new / n_dec_full);
amp_dec_full = abs(Y_dec_full(1:n_dec_full/2));
subplot(2, 1, 1, 'Parent', tab3);
t_axis_dec = (0:length(y_voice_dec)-1) / Fs_new;
plot(t_axis_dec, y_voice_dec, 'Color', [0, 0.45, 0.74], 'LineWidth', 0.8);
grid on; xlabel('Время, с'); ylabel('Амплитуда');
title(sprintf('Пункт 11: Прореженный речевой сигнал y1(t) (Fs = %d Гц, децимация x%d)', Fs_new, dec_factor));
subplot(2, 1, 2, 'Parent', tab3);
plot(freqs_orig, amp_orig_v, 'b-', 'LineWidth', 1, 'DisplayName', 'Оригинал (Fs = 44100 Гц)');
hold on;
plot(freqs_dec_full, amp_dec_full, 'r-', 'LineWidth', 1.2, 'DisplayName', sprintf('Прореженный (Fs = %d Гц, алиасинг)', Fs_new));
grid on; xlabel('Частота, Гц'); ylabel('Амплитуда');
title('Пункт 12: Спектральный анализ и проявление эффекта наложения спектров (алиасинга)');
legend('Location', 'NorthEast');
xlim([0, Fs_new+1]); 
hold off;


tab4 = uitab(tabGroup, 'Title', 'Пункт 13: Разрядность АЦП (3, 4, 5, 6 бит)');
bits_array = [3, 4, 5, 6];
frequencies_d = (0:double(N_base)-1) * (fs_base / double(N_base));
freqs_half = frequencies_d(1:double(N_base)/2 - 1);

Y_d_full = zeros(1, N_b_double);
for k = 0:N_b_double-1
    sum_val = 0;
    for n = 0:N_b_double-1
        sum_val = sum_val + y_d(n+1) * exp(-1j * 2 * pi * k * n / N_b_double);
    end
    Y_d_full(k+1) = sum_val;
end

amp_d_half = abs(Y_d_full(1:double(N_base)/2 - 1));


fprintf('[Пункт 13] Исследование разрядности АЦП:\n');
for i = 1:length(bits_array)
    b = bits_array(i);
    levels = 2^b;
    max_val = max(abs(y_d));
    
    y_norm = (y_d + max_val) / (2 * max_val); 
    y_quant_levels = round(y_norm * (levels - 1));
    y_quant = (y_quant_levels / (levels - 1)) * (2 * max_val) - max_val;
    
    rmse_err = sqrt(mean((y_d - y_quant).^2));
    signal_range = 2 * max_val;
    rel_err_pct = (rmse_err / signal_range) * 100;
    
    fprintf('           - Разрядность %d бит (%2d уровней): RMSE = %.5f (Относительная: %.2f%%)\n', ...
            b, levels, rmse_err, rel_err_pct);
    
    Y_q = zeros(1, N_b_double);
    for k = 0:N_b_double-1
        sum_val = 0;
        for n = 0:N_b_double-1
            sum_val = sum_val + y_quant(n+1) * exp(-1j * 2 * pi * k * n / N_b_double);
        end
        Y_q(k+1) = sum_val;
    end
    
    amp_q = abs(Y_q(1:double(N_base)/2 - 1));
    
    subplot(2, 2, i, 'Parent', tab4);
    plot(freqs_half, amp_d_half, 'b-', 'LineWidth', 1.2, 'DisplayName', 'Без квантования');
    hold on;
    plot(freqs_half, amp_q, 'r--', 'LineWidth', 1, 'DisplayName', sprintf('АЦП %d бит', b));
    grid on; xlabel('Частота (Гц)'); ylabel('Амплитуда');
    title(sprintf('%d бит (%d ур.), RMSE: %.4f', b, levels, rmse_err));
    legend('Location', 'NorthEast');
    xlim([0, 131]);
    hold off;
end
fprintf('========================================================================\n');