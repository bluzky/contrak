defmodule Contrak do
  @moduledoc """

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

  Shorthand form if you only check for type:
  `<field_name>: <type>`

  - `type` is all types supported by `Valdi.validate_type`, and extended to support nested type.
    Nested type is just another schema.

  - `default`: could be a function `func/0` or a value. Default function is invoked for every time `validate` is called.
    If not set, default value is `nil`

  - `required`: if set to `true`, validate if a field does exist and not `nil`. Default is `false`.

  - `validations`: all validation support by `Valdi`, if value is `nil` then all validation is skip

  For more details, please check document for `Contrak.Schema`

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

  **Another example**
  ```elixir
  @update_user_contract %{
    user: [type: User, required: true],
    attributes: [type: %{
      email: [type: :string],
      status: [type: :string, in: ~w(active in_active)]
      age: [type: :integer, number: [min: 10, max: 80]],
    }, required: true]
  }

  def update_user(contract) do
    with {:ok, validated_data} do
       validated_data.user
       |> Ecto.Changeset.change(validated_data.attributes)
       |> Repo.update
    else
      {:error, errors} -> IO.inspect(errors)
    end
  end

  ```
  """

  @doc """
  Validate data against given schema
  """

  @spec validate(data :: map(), schema :: map()) :: {:ok, map()} | {:error, errors :: map()}
  def validate(data, schema) do
    {status, results} =
      schema
      |> Contrak.Schema.expand()
      |> Enum.map(fn {field_name, validations} ->
        {default, validations} = Keyword.pop(validations, :default)
        value = Map.get(data, field_name, default)

        validations = sort_validator(validations)

        {status, results} =
          Enum.reduce(validations, {:ok, value}, fn
            _, {:error, _} = error ->
              error

            validation, acc ->
              case do_validate(value, validation, data) do
                :ok -> acc
                {:ok, data} -> {:ok, data}
                {:error, msg} when is_list(msg) -> {:error, msg}
                {:error, msg} -> {:error, [msg]}
              end
          end)

        {status, {field_name, results}}
      end)
      |> collect_schema_result()

    {status, Map.new(results)}
  end

  # prioritize checking
  # `required` -> `type` -> others
  defp sort_validator(validators) do
    {required, validators} = Keyword.pop(validators, :required, false)
    {type, validators} = Keyword.pop(validators, :type, :any)
    validators = [{:type, type} | validators]
    [{:required, required} | validators]
  end

  defp do_validate(value, {:required, _} = validation, _),
    do: Valdi.validate(value, [validation])

  # skip other validation if nil
  defp do_validate(nil, _, _), do: :ok
  # validate nested type
  defp do_validate(value, {:type, type}, _) when is_map(type) do
    Valdi.validate_embed(value, {:embed, __MODULE__, type})
  end

  defp do_validate(value, {:type, {:array, type}}, _) when is_map(type) do
    Valdi.validate_embed(value, {:array, {:embed, __MODULE__, type}})
  end

  defp do_validate(value, {:func, func}, opts) when is_function(func, 3) do
    func.(opts[:field_name], value, opts[:data])
  end

  defp do_validate(value, validation, _), do: Valdi.validate(value, [validation])

  defp collect_schema_result(results) do
    Enum.reduce(results, {:ok, []}, fn
      {:ok, data}, {:ok, acc} -> {:ok, [data | acc]}
      {:error, error}, {:ok, _} -> {:error, [error]}
      {:error, error}, {:error, acc} -> {:error, [error | acc]}
      _, acc -> acc
    end)
  end
end
