defmodule Devi.Core.GeneralLedger do
  @moduledoc """
  The general ledger is the source of truth. It stores a record of all availale
  accounts and all transactions which alter the value of those accounts.

  The last of available accounts is known as the "Chart of Accounts"

  The list of all transations altering the value of those accounts is known as
  the Journel Entries. Transactions are added to the list of journal entries
  through functions:

  - `Devi.Core.GeneralLedger.EnterTransactionearn_asset_revenue/2`
  - `Devi.Core.GeneralLedger.EnterTransactionmake_contribution/2`
  - `Devi.Core.GeneralLedger.EnterTransactionpay_dividend/2`
  - `Devi.Core.GeneralLedger.EnterTransactionpay_expenses/2`
  - `Devi.Core.GeneralLedger.EnterTransactionpay_on_account/2`
  - `Devi.Core.GeneralLedger.EnterTransactionpurchase_on_account/2`
  - `Devi.Core.GeneralLedger.EnterTransactionpurchase_with_asset/2`
  """

  alias Devi.Core.Dateable
  alias Devi.Core.GeneralLedger.Account
  alias Devi.Core.GeneralLedger.ChartOfAccounts
  alias Devi.Core.GeneralLedger.EnterTransaction
  alias Devi.Core.GeneralLedger.Transaction

  defdelegate account_types, to: Account

  defdelegate earn_asset_revenue(ledger, params), to: EnterTransaction
  defdelegate make_contribution(ledger, params), to: EnterTransaction
  defdelegate pay_dividend(ledger, params), to: EnterTransaction
  defdelegate pay_expenses(ledger, params), to: EnterTransaction
  defdelegate pay_on_account(ledger, params), to: EnterTransaction
  defdelegate purchase_on_account(ledger, params), to: EnterTransaction
  defdelegate purchase_with_asset(ledger, params), to: EnterTransaction

  @type account_id :: ChartOfAccounts.id_type()
  @type t :: %__MODULE__{
          journal_entries: list(Transaction.t()),
          chart_of_accounts: ChartOfAccounts.t()
        }
  @type filter_information ::
          %{period_before: Dateable.date_value()}
          | %{period_start: Dateable.date_value(), period_end: Dateable.date_value()}

  defstruct chart_of_accounts: %{},
            journal_entries: []

  @doc """
  Adds an acoount to the chart of accounts.

  This method leaves it up to the caller to ensure that the given account
  complies with Devi.Core.GeneralLedger.Account.t. If the given acocunt type is
  not valid any transactions which attept to use the account will cause the
  ledger to fall out of balance.

  To update an existing account use update_account.
  """
  @spec add_account(t, Account.t()) :: t
  def add_account(
        %__MODULE__{chart_of_accounts: accounts} = ledger,
        %{id: id, type: _type} = account
      ) do
    unless is_nil(accounts[id]),
      do: raise(ArgumentError, message: "This account is already registered")

    put_in(ledger, [Access.key(:chart_of_accounts), id], account)
  end

  @doc """
  Updates an account in the chart of accounts

  Accounts in Devi need only have an `:id` and `:type` key. We expect Account
  structs to be defined by 3rd party systems which might include any number of
  additional fields - which can be updated in Devi using  this method.

  We do not allow changes to the type field - 
  """
  @spec update_account(t, Account.t()) :: t
  def update_account(
        %__MODULE__{chart_of_accounts: accounts} = ledger,
        %{id: id, type: type} = account
      ) do
    if accounts[id].type != type,
      do: raise(ArgumentError, message: "The account type can not be safely changed")

    put_in(ledger, [Access.key(:chart_of_accounts), id], account)
  end

  @doc """
  Returns an account by id if it is registered in the chart of accounts
  """
  @spec fetch_account!(t, any) :: Account.t()
  def fetch_account!(ledger, id) do
    ledger
    |> get_in([Access.key(:chart_of_accounts), id])
    |> case do
      nil -> raise RuntimeError, message: "Not found"
      account -> account
    end
  end
end
