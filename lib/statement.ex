defmodule Devi.Core.Statement do
  @moduledoc """
  Statements are documents used to communicate information needed to make
  financial decisions
  """

  alias Devi.Core.Statement.Income
  alias Devi.Core.Statement.RetainedEarnings

  defdelegate generate_income_statement(params), to: Income, as: :new
  defdelegate generate_retained_earnings_statement(params), to: RetainedEarnings, as: :new
end
