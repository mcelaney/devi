defmodule Devi.Core.Statement do
  @moduledoc """
  Statements are documents used to communicate information needed to make
  financial decisions
  """

  alias Devi.Core.Statement.Income

  defdelegate generate_income_statement(params), to: Income, as: :new
end
