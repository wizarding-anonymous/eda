# Структура проекта Restaurant Booking App

Проект организован согласно принципам Clean Architecture с использованием Flutter и следующих технологий:

## Технологический стек

- **Flutter**: Кроссплатформенный фреймворк
- **Riverpod**: Управление состоянием
- **Go Router**: Навигация
- **Dio**: HTTP клиент
- **Hive**: Локальное хранилище
- **Get It + Injectable**: Dependency Injection
- **Freezed**: Генерация immutable классов
- **JSON Annotation**: Сериализация JSON

## Структура папок

```
lib/
├── core/                           # Основная инфраструктура
│   ├── constants/                  # Константы приложения
│   │   └── app_constants.dart
│   ├── di/                        # Dependency Injection
│   │   ├── injection.dart
│   │   └── injection.config.dart  # Генерируемый файл
│   ├── error/                     # Обработка ошибок
│   │   └── failures.dart
│   ├── network/                   # Сетевые утилиты
│   │   ├── api_result.dart
│   │   └── api_result.freezed.dart # Генерируемый файл
│   ├── router/                    # Навигация
│   │   └── app_router.dart
│   └── utils/                     # Утилиты
│       ├── formatters.dart
│       └── validators.dart
├── data/                          # Слой данных
│   └── datasources/
│       ├── local/                 # Локальные источники данных
│       │   └── local_storage.dart
│       └── remote/                # Удаленные источники данных
│           └── api_client.dart
├── domain/                        # Бизнес-логика
│   ├── entities/                  # Сущности предметной области
│   │   ├── auth.dart
│   │   ├── menu.dart
│   │   ├── payment.dart
│   │   ├── reservation.dart
│   │   ├── user.dart
│   │   └── venue.dart
│   └── repositories/              # Интерфейсы репозиториев
│       ├── auth_repository.dart
│       ├── booking_repository.dart
│       ├── payment_repository.dart
│       └── venue_repository.dart
├── presentation/                  # Слой представления
│   └── pages/
│       ├── home/
│       │   └── home_page.dart
│       └── splash/
│           └── splash_page.dart
└── main.dart                      # Точка входа
```

## Основные компоненты

### Core Layer (Ядро)
- **Constants**: Константы для API, ключей хранилища, валидации
- **DI Container**: Настройка зависимостей с get_it и injectable
- **Error Handling**: Типизированные ошибки (NetworkFailure, ServerFailure, etc.)
- **API Result**: Wrapper для результатов API вызовов
- **Router**: Настройка навигации с go_router
- **Validators**: Валидация форм (email, телефон, пароль)
- **Formatters**: Форматирование данных (валюта, дата, телефон)

### Data Layer (Данные)
- **Local Storage**: Hive для локального хранения (токены, пользователь, избранное)
- **API Client**: Dio клиент с автоматическим обновлением токенов

### Domain Layer (Предметная область)
- **Entities**: Основные сущности системы
  - User: Пользователь с настройками
  - Venue: Заведение с адресом и расписанием
  - Reservation: Бронирование с предзаказом
  - Menu: Меню с категориями и модификаторами
  - Payment: Платежи и чеки
  - Auth: Аутентификация и авторизация
- **Repository Interfaces**: Контракты для работы с данными

### Presentation Layer (Представление)
- **Pages**: Экраны приложения
- **Splash Page**: Экран загрузки с инициализацией
- **Home Page**: Главный экран приложения

## Следующие шаги

Базовая инфраструктура проекта готова. Для продолжения разработки необходимо:

1. Реализовать конкретные репозитории в data layer
2. Создать провайдеры состояния с Riverpod
3. Разработать UI компоненты и экраны
4. Добавить тесты для всех слоев
5. Интегрировать внешние сервисы (карты, платежи, SMS)

## Команды для разработки

```bash
# Установка зависимостей
flutter pub get

# Генерация кода
dart run build_runner build

# Анализ кода
flutter analyze

# Запуск тестов
flutter test

# Сборка для web
flutter build web

# Запуск приложения
flutter run
```