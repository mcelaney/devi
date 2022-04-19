defmodule Devi.Core.GeneralLedger.Transaction do
  @moduledoc """
  A transaction is a measurable event that affects the financial position of the
  business. In double entry accounting transactions will always involve two
  account_entries to the ledger and need to leave the accounting equation in
  balance.

  See `Devi.Core.GeneralLedger.EnterTransaction` for more information on creating
  these structs
  """

  @type t :: %__MODULE__{}

  defstruct ~w[account_entries inserted_at]a
end
