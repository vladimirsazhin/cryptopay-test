# Тестовое задание для cryptopay

В требованиях не было указано в каком формате возвращать ошибки,
я выбрал формат [JSON API](https://jsonapi.org/format/#error-objects).

## Запуск в консоли

```
bundle
createdb cryptopay-test
export POSTGRES_URL=postgres://localhost/cryptopay-test
bundle exec sequel -m migrations $POSTGRES_URL
bundle exec rackup
```

Приложение будет доступно по адресу http://localhost:9292.

## Примеры запросов

Создание пользователя:

```
$ curl -i -X POST -d '{"email": "john@example.com"}' http://localhost:9292/users
HTTP/1.1 201 Created
Content-Type: application/json
Content-Length: 98

{
  "data": {
    "id": "34461d71-534c-429c-9278-31e691c7fa81",
    "email": "john@example.com"
  }
}
```

Пользователь с таким адресом уже существует:

```
$ curl -i -X POST -d '{"email": "john@example.com"}' http://localhost:9292/users
HTTP/1.1 400 Bad Request
Content-Type: application/json
Transfer-Encoding: chunked

{
  "errors": [
    {
      "code": "email_already_exists"
    }
  ]
}
```

Некорректно указан email:

```
$ curl -i -X POST -d '{"email": "john"}' http://localhost:9292/users
HTTP/1.1 400 Bad Request
Content-Type: application/json
Transfer-Encoding: chunked

{
  "errors": [
    {
      "code": "wrong_email_format"
    }
  ]
}
```

Email не указан:

```
$ curl -i -X POST http://localhost:9292/users
HTTP/1.1 400 Bad Request
Content-Type: application/json
Transfer-Encoding: chunked

{
  "errors": [
    {
      "code": "email_missing"
    }
  ]
}
```

Получение списка всех пользователей:

```
$ curl -i http://localhost:9292/users
HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{
  "data": [
    {
      "id": "34461d71-534c-429c-9278-31e691c7fa81",
      "email": "john@example.com"
    },
    {
      "id": "e038d4aa-0032-4fb5-9ed9-9ea677302517",
      "email": "foo@gmail.com"
    },
    {
      "id": "cf5e66bc-48d0-4acc-ad6f-2a14265f9ab0",
      "email": "bar@gmail.com"
    },
    {
      "id": "df007e99-5e91-47db-ab88-872e8b0617e5",
      "email": "baz@gmail.com"
    }
  ]
}
```

Получение пользователя по id:

```
$ curl -i http://localhost:9292/users/34461d71-534c-429c-9278-31e691c7fa81
HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{
  "data": {
    "id": "34461d71-534c-429c-9278-31e691c7fa81",
    "email": "john@example.com"
  }
}
```

Некорректные запросы:

```
$ curl -i http://localhost:9292/foo
HTTP/1.1 404 Not Found
Content-Type: application/json
Transfer-Encoding: chunked

{
  "errors": [
    {
      "code": "not_found"
    }
  ]
}
```

```
$ curl -i -X POST -d '}{' http://localhost:9292/users
HTTP/1.1 400 Bad Request
Content-Type: application/json
Transfer-Encoding: chunked

{
  "errors": [
    {
      "code": "bad_request"
    }
  ]
}
```
