defmodule Devi.Core.Transaction.CreateCommands do
  @moduledoc """
  Provides functions for creating transactions to ensure correct handling of
  account entry
  """

  alias Devi.Core.AccountEntry
  alias Devi.Core.Transaction

  @doc """
  For use when an owner wants to make a contribution of some asset.

  Example - a shareholder buys stock

    iex> Core.make_contribution(%{owner: :mac, asset: :cash, amount: 30000}, now)
  """
  @spec make_contribution(%{owner: any, asset: any, amount: pos_integer}, DateTime.t()) ::
          Transaction.t()
  def make_contribution(%{owner: owner, asset: asset, amount: amount}, now \\ DateTime.utc_now()) do
    new(
      [
        AccountEntry.new(%{
          account: {:asset, asset},
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: {:capital, owner},
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  ######
  #
  #
  # Make Purchases
  #
  #
  ###

  @doc """
  For use when there will be a trade of one asset for another 

  Example - purchase office supplies for cash

    iex> Core.purchase_with_asset(%{to: :supplies, from: :cash, amount: 500}, now)
  """
  @spec purchase_with_asset(%{from: any, to: any, amount: pos_integer}, DateTime.t()) ::
          Transaction.t()
  def purchase_with_asset(%{from: from, to: to, amount: amount}, now \\ DateTime.utc_now()) do
    new(
      [
        AccountEntry.new(%{
          account: {:asset, from},
          amount: amount,
          type: :decrease,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: {:asset, to},
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  @doc """
  For use when an asset will be aquired in exchage for a liability

  Example - purchase office supplies on credit

    iex> Core.purchase_on_account(%{asset: :supplies, account: :accounts_payable, amount: 500}, now)
  """
  @spec purchase_on_account(%{asset: any, account: any, amount: pos_integer}, DateTime.t()) ::
          Transaction.t()
  def purchase_on_account(
        %{asset: asset, account: account, amount: amount},
        now \\ DateTime.utc_now()
      ) do
    new(
      [
        AccountEntry.new(%{
          account: {:liability, account},
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: {:asset, asset},
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  ######
  #
  #
  # Earn Revenue
  #
  #
  ###

  @doc """
  For use when revenue if earned

  Example - a customer owes an amount of cash for servcies rendered

    iex> Core.earn_asset_revenue(%{asset: :accounts_receivable, revenue: :service, amount: 3000}, now)
  """
  @spec earn_asset_revenue(%{asset: any, revenue: any, amount: pos_integer}, DateTime.t()) ::
          Transaction.t()
  def earn_asset_revenue(
        %{asset: asset, revenue: revenue, amount: amount},
        now \\ DateTime.utc_now()
      ) do
    new(
      [
        AccountEntry.new(%{
          account: {:asset, asset},
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: {:revenue, revenue},
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  ######
  #
  #
  # Make Payments
  #
  #
  ###

  @doc """
  For use when paying off liabilities

  Example - a customer pays an invoice with cash

    iex> Core.pay_on_account(%{asset: :cash, payment: :accounts_payable, amount: 300}, now)
  """
  @spec pay_on_account(%{asset: any, payment: any, amount: pos_integer}, DateTime.t()) ::
          Transaction.t()
  def pay_on_account(%{asset: asset, payment: payment, amount: amount}, now \\ DateTime.utc_now()) do
    new(
      [
        AccountEntry.new(%{
          account: {:liability, payment},
          amount: amount,
          type: :decrease,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: {:asset, asset},
          amount: amount,
          type: :decrease,
          inserted_at: now
        })
      ],
      now
    )
  end

  @doc """
  For use when paying for an expense

  Example - a cash payment for rent

    iex> Core.pay_expenses(%{expense: :rent, asset: :cash, amount: 2000}, now)
  """
  @spec pay_expenses(%{asset: any, expense: any, amount: pos_integer}, DateTime.t()) ::
          Transaction.t()
  def pay_expenses(%{asset: asset, expense: expense, amount: amount}, now \\ DateTime.utc_now()) do
    new(
      [
        AccountEntry.new(%{
          account: {:expense, expense},
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: {:asset, asset},
          amount: amount,
          type: :decrease,
          inserted_at: now
        })
      ],
      now
    )
  end

  @doc """
  For use when paying shareholder dividends

  Note - there is no enforced connection between capital accounts and dividend
  accounts but in practice there is probably a correlation between the two

  Example - a divident payment to an owner.

    iex> Core.pay_dividend(%{dividend: :mac, asset: :cash, amount: 5000}, now)
  """
  @spec pay_dividend(%{asset: any, dividend: any, amount: pos_integer}, DateTime.t()) ::
          Transaction.t()
  def pay_dividend(%{asset: asset, dividend: dividend, amount: amount}, now \\ DateTime.utc_now()) do
    new(
      [
        AccountEntry.new(%{
          account: {:dividend, dividend},
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: {:asset, asset},
          amount: amount,
          type: :decrease,
          inserted_at: now
        })
      ],
      now
    )
  end

  # This is here rather than on Transaction to emphasize the need to use the
  #   public interface to crete
  defp new([_ | [_ | _]] = account_entries, now) do
    %Transaction{
      account_entries: account_entries,
      inserted_at: now
    }
  end
end
