import 'package:flutter/material.dart';

/// Цветовая палитра приложения в современном стиле
class AppColors {
  AppColors._();

  // Светлая тема
  static const lightPrimary = Color(0xFF000000); // Чистый черный для заголовков
  static const lightPrimarySoft = Color(0xFF1A1A1A); // Мягкий черный для текста
  static const lightSecondary =
      Color(0xFF6B7280); // Серый для вторичного текста
  static const lightAccent = Color(0xFF2563EB); // Синий для акцентов и кнопок

  // Фоны светлой темы
  static const lightBackground = Color(0xFFFFFFFF); // Белый фон
  static const lightSurface =
      Color(0xFFFAFAFA); // Светло-серый для поверхностей
  static const lightCardBackground = Color(0xFFFFFFFF); // Белый для карточек
  static const lightOverlay = Color(0x80000000); // Полупрозрачный для оверлеев

  // Текст светлой темы
  static const lightTextPrimary = Color(0xFF000000); // Основной текст
  static const lightTextSecondary = Color(0xFF6B7280); // Вторичный текст
  static const lightTextTertiary = Color(0xFF9CA3AF); // Третичный текст
  static const lightTextOnDark = Color(0xFFFFFFFF); // Текст на темном фоне

  // Темная тема
  static const darkPrimary = Color(0xFFFFFFFF); // Белый для заголовков
  static const darkPrimarySoft = Color(0xFFF9FAFB); // Мягкий белый для текста
  static const darkSecondary =
      Color(0xFF9CA3AF); // Светло-серый для вторичного текста
  static const darkAccent = Color(0xFF3B82F6); // Синий для акцентов

  // Фоны темной темы
  static const darkBackground = Color(0xFF000000); // Черный фон
  static const darkSurface = Color(0xFF111111); // Темно-серый для поверхностей
  static const darkCardBackground =
      Color(0xFF1F1F1F); // Темно-серый для карточек
  static const darkOverlay = Color(0x80000000); // Полупрозрачный для оверлеев

  // Текст темной темы
  static const darkTextPrimary = Color(0xFFFFFFFF); // Основной текст
  static const darkTextSecondary = Color(0xFFD1D5DB); // Вторичный текст
  static const darkTextTertiary = Color(0xFF9CA3AF); // Третичный текст
  static const darkTextOnDark = Color(0xFF000000); // Текст на светлом фоне

  // Состояния (одинаковые для обеих тем)
  static const success = Color(0xFF059669); // Зеленый для успеха
  static const warning = Color(0xFFD97706); // Оранжевый для предупреждений
  static const error = Color(0xFFDC2626); // Красный для ошибок
  static const info = Color(0xFF2563EB); // Синий для информации

  // Рейтинг и звезды
  static const ratingActive = Color(0xFFFBBF24); // Золотой для активных звезд
  static const lightRatingInactive =
      Color(0xFFE5E7EB); // Серый для неактивных звезд (светлая тема)
  static const darkRatingInactive =
      Color(0xFF374151); // Темно-серый для неактивных звезд (темная тема)

  // Границы и разделители
  static const lightBorder = Color(0xFFE5E7EB); // Светло-серый для границ
  static const lightDivider =
      Color(0xFFF3F4F6); // Очень светлый для разделителей
  static const darkBorder = Color(0xFF374151); // Темно-серый для границ
  static const darkDivider = Color(0xFF1F2937); // Очень темный для разделителей

  // Кнопки
  static const lightButtonPrimary = Color(0xFF000000); // Черная основная кнопка
  static const lightButtonSecondary =
      Color(0xFFF9FAFB); // Светлая вторичная кнопка
  static const lightButtonDisabled = Color(0xFFE5E7EB); // Отключенная кнопка

  static const darkButtonPrimary = Color(0xFFFFFFFF); // Белая основная кнопка
  static const darkButtonSecondary =
      Color(0xFF374151); // Темная вторичная кнопка
  static const darkButtonDisabled = Color(0xFF4B5563); // Отключенная кнопка
}
