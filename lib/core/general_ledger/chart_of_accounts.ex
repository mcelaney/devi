defmodule Devi.Core.GeneralLedger.ChartOfAccounts do
  @moduledoc """
  A chart of accounts (COA) is a master list of all accounts in an organization's
  general ledger.
  """

  alias Devi.Core.GeneralLedger.Account

  @type account_id :: Account.id_type()
  @type t :: %{optional(account_id) => Account.t()}
end
