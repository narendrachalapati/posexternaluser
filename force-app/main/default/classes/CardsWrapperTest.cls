@isTest
public with sharing class CardsWrapperTest {
    static testMethod void testParse() {
		String json=		'{'+
		'  "cards": ['+
		'    {'+
		'      "id": "ccof:CA4SEFmcEMgUz9dMwVKk6g8zEFUoAg",'+
		'      "card_brand": "VISA",'+
		'      "last_4": "1111",'+
		'      "exp_month": 11,'+
		'      "exp_year": 2028,'+
		'      "cardholder_name": "chalapati",'+
		'      "billing_address": {'+
		'        "postal_code": "10001"'+
		'      },'+
		'      "fingerprint": "sq-1-aOdmMOrjecOV5k4DofzEjhZ8VI9yW4Pp5Qe8SBe6kvs29eU_irWveN0O3ql33WwlaQ",'+
		'      "customer_id": "SVCC1607AWR9KGXG2C8GCVBXY8",'+
		'      "merchant_id": "MLT4GSWB57MYW",'+
		'      "enabled": true,'+
		'      "card_type": "CREDIT",'+
		'      "prepaid_type": "NOT_PREPAID",'+
		'      "bin": "411111",'+
		'      "created_at": "2024-06-17T14:40:51Z",'+
		'      "version": 1'+
		'    },'+
		''+
		'  ]'+
		'}';
		CardsWrapper obj = CardsWrapper.parse(json);
		System.assert(obj != null);
	}
}