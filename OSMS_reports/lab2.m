clear; clc; close all;

fprintf('===================================================================\n');
fprintf('     РАСЧЕТ РАДИОПОКРЫТИЯ МОБИЛЬНОЙ СЕТИ (ОСМС - ЗАНЯТИЕ №2)       \n');
fprintf('===================================================================\n\n');

%% Исходные данные
f_Hz        = 1.8e9;   f_MHz = 1800;   f_GHz = 1.8;   c = 3e8;
TxPower_BS  = 46.0;    TxPower_UE = 24.0;  NumSectors = 3;
AntGain_BS  = 21.0;    MIMOGain   = 3.0;
FeederLoss  = 2.0 + 0.4 + 0.5;
PenetrationM = 15.0;   IM = 1.0;
BW_UL = 10e6;          BW_DL = 20e6;
NoiseFigure_BS = 2.4;  NoiseFigure_UE = 6.0;
ReqSINR_UL = 4.0;      ReqSINR_DL = 2.0;
h_BS = 30.0;           h_ms = 1.5;
S_total_macro = 100.0; S_total_micro = 4.0;

fprintf('1. ИСХОДНЫЕ ПАРАМЕТРЫ СИСТЕМЫ:\n');
fprintf('   > Частота: %.1f МГц (%.2f ГГц)\n', f_MHz, f_GHz);
fprintf('   > Мощность передатчика: BS = %.1f дБм (%.1f Вт), UE = %.1f дБм (%.2f Вт)\n', ...
        TxPower_BS, 10^((TxPower_BS-30)/10), TxPower_UE, 10^((TxPower_UE-30)/10));
fprintf('   > Усиление антенны BS: %.1f дБи | MIMO Gain: %.1f дБ\n', AntGain_BS, MIMOGain);
fprintf('   > Потери в фидере: %.2f дБ | Запас на проникновение: %.1f дБ | Запас IM: %.1f дБ\n', ...
        FeederLoss, PenetrationM, IM);
fprintf('   > Высота подвеса: BS = %.1f м, UE = %.1f м\n\n', h_BS, h_ms);

%% Задание 1: Бюджет восхоящего канала (UL)
ThermalNoise_UL = -174 + 10 * log10(BW_UL);
RxSens_BS = ThermalNoise_UL + NoiseFigure_BS + ReqSINR_UL;
MAPL_UL = TxPower_UE - FeederLoss + AntGain_BS + MIMOGain - RxSens_BS - IM - PenetrationM;

fprintf('-------------------------------------------------------------------\n');
fprintf('2. РАСЧЕТ БЮДЖЕТА ВОСХОДЯЩЕГО КАНАЛА (UL):\n');
fprintf('   > Полоса пропускания BW_UL: %.1f МГц\n', BW_UL / 1e6);
fprintf('   > Тепловой шум (Thermal Noise): %.2f дБм\n', ThermalNoise_UL);
fprintf('   > Коэффициент шума приемника БС (NF_BS): %.2f дБ\n', NoiseFigure_BS);
fprintf('   > Требуемый SINR (UL): %.2f дБ\n', ReqSINR_UL);
fprintf('   -> Чувствительность БС (RxSens_BS): %.2f дБм\n', RxSens_BS);
fprintf('   -> Макс. допустимые потери (MAPL_UL): %.2f дБ\n\n', MAPL_UL);

%% Задание 2: Бюджет нисходящего канала (DL)
ThermalNoise_DL = -174 + 10 * log10(BW_DL);
RxSens_UE = ThermalNoise_DL + NoiseFigure_UE + ReqSINR_DL;
MAPL_DL = TxPower_BS - FeederLoss + AntGain_BS + MIMOGain - RxSens_UE - IM - PenetrationM;
delta_MAPL = MAPL_DL - MAPL_UL;

fprintf('-------------------------------------------------------------------\n');
fprintf('3. РАСЧЕТ БЮДЖЕТА НИСХОДЯЩЕГО КАНАЛА (DL):\n');
fprintf('   > Полоса пропускания BW_DL: %.1f МГц\n', BW_DL / 1e6);
fprintf('   > Тепловой шум (Thermal Noise): %.2f дБм\n', ThermalNoise_DL);
fprintf('   > Коэффициент шума приемника UE (NF_UE): %.2f дБ\n', NoiseFigure_UE);
fprintf('   > Требуемый SINR (DL): %.2f дБ\n', ReqSINR_DL);
fprintf('   -> Чувствительность терминала (RxSens_UE): %.2f дБм\n', RxSens_UE);
fprintf('   -> Макс. допустимые потери (MAPL_DL): %.2f дБ\n', MAPL_DL);

%  Задание 3: построение графиков (FSPM, COST231, UMiNLOS)
fprintf('>>> ЗАДАНИЕ 3: Моделирование распространения сигналов PL(d)\\n');

d_km_vec = linspace(0.1, 5.0, 1000);
d_m_vec  = d_km_vec * 1000;

PL_FSPM_dB = 20 * log10( (4 * pi * d_m_vec * f_Hz) / c );

% 2. Модель COST 231 Hata:
A_cost = 46.3;
B_cost = 33.9;

a_ms_urban = 3.2 * (log10(11.75 * h_ms))^2 - 4.97;

s_vec = zeros(size(d_km_vec));
for idx = 1:length(d_km_vec)
    d_val = d_km_vec(idx);
    if d_val >= 1.0
        s_vec(idx) = 44.9 - 6.55 * log10(f_MHz);
    else
        s_vec(idx) = (47.88 + 13.9 * log10(f_MHz) - 13.9 * log10(h_BS)) / log10(50.0);
    end
end

L_clutter_urban = 0.0; 
L_clutter_dense = 3.0;
L_clutter_sub   = -(2 * (log10(f_MHz / 28.0))^2 + 5.4);
L_clutter_rural = -(4.78 * (log10(f_MHz))^2 - 18.33 * log10(f_MHz) + 40.94);
L_clutter_road = -(4.78 * (log10(f_MHz))^2 - 18.33 * log10(f_MHz) + 35.94);

PL_COST_Urban = A_cost + B_cost * log10(f_MHz) - 13.82 * log10(h_BS) - a_ms_urban + s_vec .* log10(d_km_vec) + L_clutter_urban;
PL_COST_Rural = A_cost + B_cost * log10(f_MHz) - 13.82 * log10(h_BS) - a_ms_urban + s_vec .* log10(d_km_vec) + L_clutter_rural;

% 3. Модель Walfish-Ikegami
h_roof = 20.0;
w_st   = 20.0;
b_bld  = 50.0;
phi_st = 90.0;

PL_WI_LOS = 42.6 + 20 * log10(f_MHz) + 26 * log10(d_km_vec);

L0_vec = 32.44 + 20 * log10(f_MHz) + 20 * log10(d_km_vec);

if phi_st < 35
    L_ori = -10.0 + 0.354 * phi_st;
elseif phi_st < 55
    L_ori = 2.5 + 0.075 * phi_st;
else
    L_ori = 4.0 - 0.114 * phi_st;
end
delta_h_diff = max(h_roof - h_ms, 1.0);
L2_val = -16.9 - 10 * log10(w_st) + 10 * log10(f_MHz) + 20 * log10(delta_h_diff) + L_ori;

if h_BS > h_roof
    L11 = -18.0 * log10(1.0 + h_BS - h_roof);
    ka  = 54.0;
    kd  = 18.0;
else
    L11 = 0.0;
    ka  = 54.0 - 0.8 * (h_BS - h_roof);
    kd  = 18.0 - 15.0 * (h_BS - h_roof) / h_roof;
end
kf = -4.0 + 0.7 * (f_MHz / 925.0 - 1.0);

L1_vec = L11 + ka + kd * log10(d_km_vec) + kf * log10(f_MHz) - 9.0 * log10(b_bld);

diff_sum = L1_vec + L2_val;
PL_WI_NLOS = L0_vec + max(diff_sum, 0);

% 4. Модель UMiNLOS:
PL_UMiNLOS_macro = 26 * log10(f_GHz) + 22.7 + 36.7 * log10(d_m_vec);

fig1 = figure('Name', 'Сравнение моделей распространения сигналов', 'Color', 'w', 'Position', [100 100 950 580]);
%plot(d_km_vec, PL_FSPM_dB, ':', 'LineWidth', 1.8, 'Color', [0.45 0.45 0.45], 'DisplayName', 'FSPM (Свободное пространство, вакуум)');
hold on;
plot(d_km_vec, PL_COST_Urban, '-',  'LineWidth', 2.5, 'Color', [0.85 0.35 0.1], 'DisplayName', 'COST 231 Hata (Город / Urban)');
plot(d_km_vec, PL_WI_NLOS, '-.', 'LineWidth', 2.2, 'Color', [0.15 0.65 0.25], 'DisplayName', 'Walfish-Ikegami NLOS (Кварталы)');
plot(d_km_vec, PL_UMiNLOS_macro, ':', 'LineWidth', 2.0, 'Color', [0.7 0.2 0.7], 'DisplayName', 'UMiNLOS (Indoor / микросоты)');

% Горизонтальные линии порогов MAPL:
yline(MAPL_DL, '--b', sprintf('MAPL DL = %.1f дБ', MAPL_DL), 'LineWidth', 1.8, 'DisplayName', 'Порог MAPL DL');
yline(MAPL_UL, '--r', sprintf('MAPL UL = %.1f дБ', MAPL_UL), 'LineWidth', 1.8, 'DisplayName', 'Порог MAPL UL');

grid on; box on;
xlabel('Расстояние между БС и абонентом d, км', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Потери мощности радиосигнала PL(d), дБ', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Сравнение моделей распространения сигналов (f = %d МГц, h_{BS} = %d м)', f_MHz, h_BS), 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 9);
xlim([0.1 5.0]);
ylim([70 175]);

%% Задание 4:
% Для макро-соты (COST 231 Hata Urban):
d_UL_macro_km = interp1(PL_COST_Urban, d_km_vec, MAPL_UL, 'linear');
d_DL_macro_km = interp1(PL_COST_Urban, d_km_vec, MAPL_DL, 'linear');

R_macro_km    = min(d_UL_macro_km, d_DL_macro_km);
S_site_macro  = 1.95 * (R_macro_km)^2;
N_macro       = ceil(S_total_macro / S_site_macro);

% Для микро-соты (UMi-NLOS):
d_UL_micro_m = interp1(PL_UMiNLOS_macro, d_m_vec, MAPL_UL, 'linear');
R_micro_km   = d_UL_micro_m / 1000.0;
S_site_micro = 1.95 * (R_micro_km)^2;
N_micro      = ceil(S_total_micro / S_site_micro);

fprintf('-------------------------------------------------------------------\n');
fprintf('4. Расчёт покрытия:\n');
fprintf('   [Сакро-сеть / COST 231 Hata Urban]:\n');
fprintf('   > Предельная дальность UL: %.3f км\n', d_UL_macro_km);
fprintf('   > Предельная дальность DL: %.3f км\n', d_DL_macro_km);
fprintf('   -> Расчетный радиус соты R_macro: %.3f км\n', R_macro_km);
fprintf('   -> Площадь покрытия одного сайта (3 сектора): %.3f км\n', S_site_macro);
fprintf('   -> Требуемое число БС на %.1f км: %d шт.\n\n', S_total_macro, N_macro);

fprintf('   [Микро-сеть / UMi-NLOS Indoor]:\n');
fprintf('   > Предельная дальность UL: %.1f м\n', d_UL_micro_m);
fprintf('   -> Расчетный радиус микросоты R_micro: %.4f км\n', R_micro_km, d_UL_micro_m);
fprintf('   -> Площадь покрытия микросайта: %.4f км\n', S_site_micro, S_site_micro * 1e6);
fprintf('   -> Требуемое число БС: %d шт.\n\n', S_total_micro, N_micro);

%   ------------------Дополнительное задание: Зависимость Cell Range от высот h_BS и h_ms

h_BS_range = linspace(30, 200, 200);
h_ms_range = linspace(1.0, 10.0, 200);

s_macro = 44.9 - 6.55 * log10(f_MHz);
PL_base = A_cost + B_cost * log10(f_MHz) + L_clutter_urban;

a_ms_fixed = 3.2 * (log10(11.75 * h_ms))^2 - 4.97;
a_ms_vec   = 3.2 * (log10(11.75 * h_ms_range)).^2 - 4.97;

R_vs_hBS_km = 10 .^ ((MAPL_UL - (PL_base - 13.82*log10(h_BS_range) - a_ms_fixed)) / s_macro);
R_vs_hms_km = 10 .^ ((MAPL_UL - (PL_base - 13.82*log10(h_BS)       - a_ms_vec))   / s_macro);

fig2 = figure('Name', 'Cell Range vs Высоты антенн', 'Color', 'w', 'Position', [100 100 950 500]);

yyaxis left
plot(h_BS_range, R_vs_hBS_km, '-o', 'LineWidth', 2.5, 'MarkerIndices', 1:20:200);
ylabel('Радиус соты R, км (от h_{BS})', 'FontWeight', 'bold');
xlabel('Высота БС h_{BS}, м', 'FontWeight', 'bold');

yyaxis right
plot(h_ms_range, R_vs_hms_km, '-o', 'LineWidth', 2.5, 'MarkerIndices', 1:20:200);
ylabel('Радиус соты R, км (от h_{ms})', 'FontWeight', 'bold');

grid on; box on;
title(sprintf('Зависимость Cell Range от высот антенн (f = %d МГц, MAPL_{UL} = %.1f дБ)', f_MHz, MAPL_UL), 'FontSize', 12);
legend({'R(h_{BS})', 'R(h_{ms})'}, 'Location', 'northwest');