from typing import Dict, Tuple
import os
import numpy as np
import pandas as pd
from scipy.stats import norm
import datetime

API_KEY = os.getenv('API_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')

class InvalidTradeActionError(Exception):
    """Raised when an invalid trade action is detected."""
    pass

class FinancialInstrument:
    def __init__(self, symbol: str):
        self.symbol = symbol

    def assess_risk(self):
        pass

    def trade(self, action: str, quantity: int):
        if action.lower() not in ['buy', 'sell']:
            raise InvalidTradeActionError(f"{action} is not a valid trading action. Use 'buy' or 'sell'.")
        self._execute_trade(action, quantity)

    def _execute_trade(self, action: str, quantity: int):
        try:
            print(f"Executing {action} on {quantity} units of {self.symbol}")
        except Exception as e:
            print(f"Failed to execute trade for {self.symbol}: {e}")

class Derivative(FinancialInstrument):
    def __init__(self, symbol: str, underlying_asset: str, maturity_date: str, strike_price: float):
        super().__init__(symbol)
        self.underlying_asset = underlying_asset
        self.maturity_date = maturity_date
        self.strike_price = strike_price

    def assess_risk(self, spot_price: float, volatility: float, risk_free_rate: float, time_to_maturity: float) -> Dict[str, float]:
        try:
            call_option_price = self._calculate_call_option_price(spot_price, volatility, risk_free_rate, time_to_maturity)
            return {"call_option_price": call_option_binprice}
        except ZeroDivisionError:
            print("Error: Division by zero encountered in risk assessment calculations.")
            return {}
        except ValueError as e:
            print(f"Value error: {e}")
            return {}

    def _calculate_call_option_price(self, spot_price: float, volatility: float, risk_free_rate: float, time_to_maturity: float) -> float:
        try:
            d1, d2 = self._calculate_d1_d2(spot_price, volatility, risk_free_rate, time_to_maturity)
            call_option_price = (spot_price * norm.cdf(d1) - self.strike_price * np.exp(-risk_free_rate * time_to_maturity) * norm.cdf(d2))
            return call_option_price
        except Exception as e:
            print(f"Error calculating the call option price: {e}")
            return 0.0 

    def _calculate_d1_d2(self, spot_price: float, volatility: float, risk_free_rate: float, time_to_maturity: float) -> Tuple[float, float]:
        try:
            d1 = (np.log(spot_price / self.strike_price) + (risk_free_rate + 0.5 * volatility ** 2) * time_to_maturity) / (volatility * np.sqrt(time_to_maturity))
            d2 = d1 - volatility * np.sqrt(time_to_maturity)
            return d1, d2
        except Exception as e:
            print(f"Error calculating D1 and D2: {e}")
            return 0.0, 0.0 

class Bond(FinancialInstrument):
    def __init__(self, symbol: str, face_value: float, coupon_rate: float, maturity_years: int):
        super().__init__(symbol)
        if coupon_rate < 0 or coupon_rate > 1:
            raise ValueError("Coupon rate must be between 0 and 1.")
        if maturity_years < 1:
            raise ValueError("Maturity years must be at least 1.")
        self.face_value = face_value
        self.coupon_rate = coupon_rate
        self.maturity_years = maturity_years

    def assess_risk(self, market_price: float) -> Dict[str, float]:
        try:
            ytm = self._calculate_yield_to_maturity(market_price)
            return {"yield_to_maturity": ytm}
        except ZeroDivisionError:
            print("Error: Division by zero encountered in YTM calculations.")
            return {}
        except ValueError as e:
            print(f"Value error: {e}")
            return {}

    def _calculate_yield_to_maturity(self, market_price: float) -> float:
        try:
            coupon = self.face_value * self.coupon_rate
            ytm = ((coupon + (self.face_value - market_price) / self.maturity_years) / ((self.face_value + market_price) / 2))
            return ytm
        except Exception as e:
            print(f"Failed to calculate YTM: {e}")
            return 0.0 

if __name__ == "__main__":
    try:
        derivative = Derivative('Deriv1', 'AAPL', '2023-12-31', 150.00)
        bond = Bond('Bond1', 1000, 0.05, 10)

        derivative_risk = derivative.assess_risk(100, 0.2, 0.01, 1)
        bond_risk = bond.assess_risk(950)

        derivative.trade('buy', 10)
        bond.trade('sell', 5)

        print(derivative_risk)
        print(bond_risk)
    except Exception as e:
        print(f"An error occurred: {e}")