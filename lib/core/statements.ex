defmodule Devi.Core.Statements do
  @moduledoc """
  Statements are documents used to communicate information needed to make
  financial decisions
  """

  alias Devi.Core.Statements.Income
  alias Devi.Core.Statements.RetainedEarnings

  defdelegate generate_income_statement(params), to: Income, as: :new
  defdelegate generate_retained_earnings_statement(params), to: RetainedEarnings, as: :new
end
