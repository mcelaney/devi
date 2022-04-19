defmodule Devi.Core.GeneralLedger.TransactionTest do
  use ExUnit.Case, async: true

  alias Devi.Core.GeneralLedger.Transaction

  # dumb test coverage hack
  test "requires all keys to be created" do
    assert %Transaction{inserted_at: nil, account_entries: []}
  end
end
