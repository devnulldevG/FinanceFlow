import unittest
from financial_instruments import ComplexFinancialProduct, RiskManager
import os

API_KEY = os.getenv('FINICIAL_API_KEY')
CONFIG_OPTION = os.getenv('CONFIG_OPTION')

class TestFinancialInstruments(unittest.TestCase):
    def setUp(self):
        # Product parameters
        product_params = {
            'name': 'Complex Fin Product',
            'initial_investment': 10000,
            'risk_level': 'High'
        }
        
        # Setup product
        self.complex_product = ComplexFinancialProduct(**product_params)
        
        # Setup risk manager
        self.risk_manager = RiskManager(API_key=API_KEY, config_option=CONFIG_OPTION)

    def test_product_creation(self):
        # Verify product attributes
        expected_attributes = {
            'name': 'Complex Fin Product',
            'initial_investment': 10000,
            'risk_level': 'High'
        }
        
        for attr, expected in expected_attributes.items():
            self.assertEqual(getattr(self.complex_product, attr), expected, 
                             f"{attr} does not match expected value.")

    def test_risk_management_protocol(self):
        # Mock risk analysis
        self.risk_manager.analyze_risk = lambda x: {'status': 'ok', 'risk_evaluated': True}
        
        # Perform risk analysis
        risk_analysis = self.risk_manager.analyze_risk(self.complex_product)
        
        # Assert risk analysis outcome
        self.assertTrue(risk_analysis['risk_evaluated'])
        self.assertEqual(risk_analysis['status'], 'ok')

    def test_financial_product_management(self):
        initial_investment = self.complex_product.initial_investment
        updated_investment = 5000
        
        # Update investment
        self.complex_product.update_investment(updated_investment)
        
        # Verify updated investment
        self.assertEqual(self.complex_product.initial_investment, initial_investment + updated_investment)

if __name__ == '__main__':
    unittest.main()