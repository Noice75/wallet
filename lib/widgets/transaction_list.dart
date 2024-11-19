import 'package:flutter/material.dart';



class TransactionList extends StatelessWidget {

  const TransactionList({super.key});



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        _buildDateGroup(

          date: 'November 19.',

          day: 'Today',

          amount: '5,000.00 USD',

          transactions: [

            _buildTransactionItem(

              context,

              category: 'Food & Drinks',

              amount: '5,555.00',

              icon: Icons.restaurant,

              iconBackgroundColor: const Color(0xFF2AC89E),

              bankName: 'Bank',

            ),

            const SizedBox(height: 16),

            _buildTransactionItem(

              context,

              category: 'Gifts',

              amount: '555.00',

              icon: Icons.card_giftcard,

              iconBackgroundColor: Colors.pink[100]!,

              bankName: 'Bank',

            ),

          ],

        ),

        const SizedBox(height: 32),

        _buildDateGroup(

          date: 'November 17.',

          day: 'Sunday',

          amount: '5,555.00 USD',

          transactions: [

            _buildTransactionItem(

              context,

              category: 'Cash',

              amount: '5,555.00',

              icon: Icons.account_balance_wallet,

              iconBackgroundColor: const Color(0xFF2AC89E),

              showBank: false,

            ),

          ],

        ),

      ],

    );

  }



  Widget _buildDateGroup({

    required String date,

    required String day,

    required String amount,

    required List<Widget> transactions,

  }) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  date,

                  style: const TextStyle(

                    fontSize: 24,

                    fontWeight: FontWeight.bold,

                  ),

                ),

                Text(

                  day,

                  style: TextStyle(

                    color: Colors.grey[600],

                    fontSize: 16,

                  ),

                ),

              ],

            ),

            Text(

              amount,

              style: const TextStyle(

                color: Color(0xFF2AC89E),

                fontSize: 18,

                fontWeight: FontWeight.w500,

              ),

            ),

          ],

        ),

        const SizedBox(height: 16),

        ...transactions,

      ],

    );

  }



  Widget _buildTransactionItem(

    BuildContext context, {

    required String category,

    required String amount,

    required IconData icon,

    required Color iconBackgroundColor,

    String? bankName,

    bool showBank = true,

  }) {

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: const Color(0xFF1A1A1A),

        borderRadius: BorderRadius.circular(16),

      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(

              color: iconBackgroundColor,

              borderRadius: BorderRadius.circular(12),

            ),

            child: Icon(

              icon,

              color: Colors.white,

              size: 24,

            ),

          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  category,

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.w500,

                  ),

                ),

                if (showBank) ...[

                  const SizedBox(height: 4),

                  Container(

                    padding: const EdgeInsets.symmetric(

                      horizontal: 8,

                      vertical: 4,

                    ),

                    decoration: BoxDecoration(

                      color: Colors.grey[900],

                      borderRadius: BorderRadius.circular(8),

                    ),

                    child: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        const Icon(

                          Icons.account_balance,

                          size: 16,

                          color: Colors.white,

                        ),

                        const SizedBox(width: 4),

                        Text(

                          bankName!,

                          style: const TextStyle(

                            color: Colors.white,

                            fontSize: 12,

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ],

            ),

          ),

          Row(

            mainAxisSize: MainAxisSize.min,

            children: [

              Icon(

                amount.contains('-') ? Icons.arrow_upward : Icons.arrow_downward,

                color: const Color(0xFF2AC89E),

                size: 20,

              ),

              const SizedBox(width: 6),

              Text(

                '$amount USD',

                style: const TextStyle(

                  color: Colors.white,

                  fontSize: 18,

                  fontWeight: FontWeight.w500,

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }

} 






