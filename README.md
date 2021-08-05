# Contrak

**Schema and contract validation library for Elixir**

[![Build Status](https://github.com/bluzky/contrak/workflows/Elixir%20CI/badge.svg)](https://github.com/bluzky/contrak/actions) [![Coverage Status](https://coveralls.io/repos/github/bluzky/contrak/badge.svg?branch=main)](https://coveralls.io/github/bluzky/contrak?branch=main) [![Hex Version](https://img.shields.io/hexpm/v/contrak.svg)](https://hex.pm/packages/contrak) [![docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/contrak/)

## Installation

Adding `contrak` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:contrak, "~> 0.1.0"}
  ]
end
```

Documentation here [https://hexdocs.pm/contrak](https://hexdocs.pm/contrak).

## Usage
  `Contrak` helps to validate data with given schema:

  ```elixir
  task_schema = %{
    title: [type: :string, required: true, length: [min: 20]],
    description: :string,
    tag: [type: {:array, :string}, default: []]
    point: [type: :integer, number: [min: 0]],
    due_date: [type: NaiveDateTime, default: &seven_day_from_now/0] ,
    assignee: [type: {:array, User}, required: true],
    attachments: [
      type:
      {:array,
       %{
         name: [type: :string, required: true],
         url: :string
       }}
    ]
  }

  case Contrak.validate(data, task_schema) do
    {:ok, valid_data} ->
        # do your logic

    {:error, errors} ->
        IO.inspect(errors)
  end
  ```

  `Contrak` also do:
  - Support nested type
  - Clean not allowed fields

  **NOTES: Contract only validate data, not cast data**

## Schema definition

`Contrak` provide a simple schema definition:

  `<field_name>: [type: <type>, required: <true|false>, default: <value|function>, [...validation]]`
  
  ```elixir
  %{
    product_name: [type: :string, required: true, length: [min: 20]],
    sku: [type: :string, required: true],
    selling_price: [type: :integer, required: true, number: [min: 0]]
    state: [type: :string, default: "draft"]
  }
  ```

  Shorthand form if you only check for type:
  
  `<field_name>: <type>`
  
  ```elixir
  %{
    product_name: :string,
    sku: :string,
    price: :integer
  }
  ```

  - `type` is all types supported by `Valdi.validate_type`, and extended to support nested type.
    Nested type is just another schema.

  - `default`: could be a function `func/0` or a value. Default function is invoked for every time `validate` is called.
    If not set, default value is `nil`

  - `required`: if set to `true`, validate if a field does exist and not `nil`. Default is `false`.

  - `validations`: all validation support by `Valdi`, if value is `nil` then all validation is skip

  For more details, please check document for [Contrak.Schema](https://hexdocs.pm/contrak/Contrak.Schema.html)

## Validations

`Contrak` uses [Valdi](https://github.com/bluzky/valdi) to validate data. So you can use all validation from `Valdi`. This is list of available validation for current version of Valdi:

  - Validate type
  - Validate required
  - Validate `in`|`not_in` enum
  - Valiate length for `string`, `enumerable`
  - Validate number
  - Validate string against regex pattern
  - Custom validation function

  Please check [Valdi document](https://hexdocs.pm/valdi/readme.html) for more details
