import 'package:flutter/material.dart';

class MembershipTiersPage extends StatelessWidget {
  const MembershipTiersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Tiers',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: SingleChildScrollView(
        child: buildMembershipTiers(context),
      ),
    );
  }

  Widget buildMembershipTiers(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Your Membership",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildTierCard(
            title: "Basic",
            price: "Free",
            features: [
              "Daily rewards up to 50 coins",
              "Access to standard tasks",
              "Basic referral rewards",
              "Monthly lucky draw entry"
            ],
            color: Colors.grey.shade800,
            borderColor: Colors.amber.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          _buildTierCard(
            title: "Pro",
            price: "₹199/month",
            features: [
              "Daily rewards up to 200 coins",
              "Access to premium tasks",
              "Enhanced referral bonuses",
              "2× monthly lucky draw entries",
              "Ad-free experience"
            ],
            color: Colors.amber.shade900,
            borderColor: Colors.amber,
          ),
          SizedBox(height: 16),
          _buildTierCard(
            title: "Pro Plus",
            price: "₹499/month",
            features: [
              "Daily rewards up to 500 coins",
              "Access to all tasks including exclusives",
              "Maximum referral bonuses",
              "5× monthly lucky draw entries",
              "Ad-free experience",
              "Priority coin redemption",
              "Dedicated customer support"
            ],
            color: Colors.black,
            borderColor: Colors.amber,
            isGradient: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    required Color borderColor,
    bool isGradient = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        gradient: isGradient
            ? LinearGradient(
          colors: [Colors.black, Color(0xFF3A3A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: isGradient
                ? Colors.amber.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add your subscription logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                title == "Basic" ? "Current Plan" : "Upgrade Now",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}