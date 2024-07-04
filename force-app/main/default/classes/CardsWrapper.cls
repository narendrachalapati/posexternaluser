global class CardsWrapper{
	global cls_cards[] cards;
	global class cls_cards {
		public String id;	//ccof:CA4SEFmcEMgUz9dMwVKk6g8zEFUoAg
		public String card_brand;	//VISA
		public String last_4;	//1111
		public Integer exp_month;	//11
		public Integer exp_year;	//2028
		public String cardholder_name;	//chalapati
		public cls_billing_address billing_address;
		public String fingerprint;	//sq-1-aOdmMOrjecOV5k4DofzEjhZ8VI9yW4Pp5Qe8SBe6kvs29eU_irWveN0O3ql33WwlaQ
		public String customer_id;	//SVCC1607AWR9KGXG2C8GCVBXY8
		public String merchant_id;	//MLT4GSWB57MYW
		public boolean enabled;
		public String card_type;	//CREDIT
		public String prepaid_type;	//NOT_PREPAID
		public String bin;	//411111
		public String created_at;	//2024-06-17T14:40:51Z
		public Integer version;	//1
	}
	class cls_billing_address {
		public String postal_code;	//10001
	}
	global static CardsWrapper parse(String json){
		return (CardsWrapper) System.JSON.deserialize(json, CardsWrapper.class);
	}

	
}