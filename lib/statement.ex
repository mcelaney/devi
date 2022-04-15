defmodule Devi.Core.Statement do
  @moduledoc """
  Statements are documents used to communicate information needed to make
  financial decisions
  """

  alias Devi.Core.Statement.Income

  defdelegate generate_income_statement(transactions, start_date, end_date), to: Income, as: :new
end
