defmodule Devi.Core.GeneralLedger.Transaction do
  @moduledoc """
  A transaction is a measurable event that affects the financial position of the
  business. In double entry accounting transactions will always involve at least
  two account_entries that leave the accounting equation in balance.
  """

  alias Devi.Core.GeneralLedger
  alias Devi.Core.GeneralLedger.Transaction
  alias Devi.Core.LedgerEntry

  @type t :: %__MODULE__{}

  defstruct ~w[account_entries meta inserted_at]a

  @doc """
  Add a given set of entries to the given ledger through a transaction
  """
  @spec add_to_ledger(GeneralLedger.t(), list(LedgerEntry.t()), DateTime.t(), map) ::
          GeneralLedger.t()
  def add_to_ledger(
        %GeneralLedger{journal_entries: transactions} = ledger,
        [_ | [_ | _]] = entries,
        %DateTime{} = now,
        %{} = meta
      ) do
    transaction = %Transaction{
      account_entries: entries,
      meta: meta,
      inserted_at: now
    }

    Map.put(ledger, :journal_entries, [transaction | transactions])
  end
end
