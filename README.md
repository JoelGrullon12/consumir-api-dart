# consumir-api-dart

Programa en **Dart puro** (sin dependencias externas) que consume la API pública de [JSONPlaceholder](https://jsonplaceholder.typicode.com) para obtener usuarios y sus publicaciones.

## Funcionalidades

- Obtiene un **token de autenticación simulado** haciendo un POST a `/posts` y luego extrayendo un email aleatorio de `/comments` como token.
- Obtiene la **lista de usuarios** (10 usuarios) usando el token.
- Por cada ejecución, selecciona **2 a 4 usuarios aleatorios** y de cada uno **entre 1 y ~6 posts aleatorios**.
- Implementa **reintentos con backoff exponencial** (3 intentos: 1s, 2s, 4s) para manejar fallos de red (`SocketException`, `HttpException`, `TimeoutException`).
- Guarda los datos en `result/user_posts_yyyy-MM-dd-HHmmss.json` sin sobrescribir ejecuciones anteriores.

## Requisitos

- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0

## Ejecución

```bash
dart run main.dart
```

## Estructura del proyecto

```
consumir-api/
├── main.dart           # Punto de entrada (orquestación del flujo)
├── api_service.dart    # Cliente HTTP con HttpClient + retryWithBackoff
├── models.dart         # Modelos: User, Post, Comment, Address, Geo, Company
├── result/             # Directorio con los JSON generados en cada ejecución
└── README.md
```

## Formato del JSON de salida

```json
{
  "token": "Sincere@april.biz",
  "users": [
    {
      "id": 1,
      "name": "Leanne Graham",
      "username": "Bret",
      "email": "Sincere@april.biz",
      "address": {
        "street": "Kulas Light",
        "suite": "Apt. 556",
        "city": "Gwenborough",
        "zipcode": "92998-3874",
        "geo": { "lat": "-37.3159", "lng": "81.1496" }
      },
      "phone": "1-770-736-8031 x56442",
      "website": "hildegard.org",
      "company": {
        "name": "Romaguera-Crona",
        "catchPhrase": "Multi-layered client-server neural-net",
        "bs": "harness real-time e-markets"
      },
      "posts": [
        { "userId": 1, "id": 1, "title": "sunt aut...", "body": "quia et..." }
      ]
    }
  ]
}
```

## Tecnologías usadas

- **Dart** — solo librerías del SDK (`dart:io`, `dart:convert`, `dart:async`, `dart:math`)
- Sin frameworks ni dependencias externas
