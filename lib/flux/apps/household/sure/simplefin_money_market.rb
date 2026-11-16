# Mounted into config/initializers as zz_simplefin_money_market.rb so it loads
# after Sure's own simplefin.rb.
#
# Sure's SimpleFIN integration imports money-market funds such as VMFXX as
# holdings, but its balance calculator also counts them as cash, so the
# settlement fund shows up twice: as "Brokerage cash" and as a VMFXX holding,
# with weights summing past 100%. The imported Vanguard history treats VMFXX
# as a fund too, so with no money-market exceptions cash is simply total minus
# holdings, and the fund appears once.
Rails.application.configure do
  config.x.simplefin.money_market_tickers = [].freeze
  config.x.simplefin.money_market_patterns = [].freeze
end
