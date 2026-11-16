import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/referred_user_model.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class ReferralListScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const ReferralListScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<ReferralListScreen> createState() => _ReferralListScreenState();
}

class _ReferralListScreenState extends State<ReferralListScreen> {
  bool isLoading = true;
  List<ReferredUserModel> referrals = [];

  @override
  void initState() {
    super.initState();
    fetchReferrals();
  }

  Future<void> fetchReferrals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Request().get(Url.appShareReferrals(widget.userId));
      
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data']['referrals'] ?? [];
        setState(() {
          referrals = dataList.map((e) => ReferredUserModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching referrals: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Referral ${widget.userName}',
          style: pBold16.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchReferrals,
        color: Theme.of(context).primaryColor,
        child: isLoading
            ? _buildLoading()
            : referrals.isEmpty
                ? _buildEmptyState()
                : _buildList(),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).highlightColor,
          highlightColor: Theme.of(context).splashColor,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.user_1,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada teman yang diundang',
            style: pMedium14.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: referrals.length,
      itemBuilder: (context, index) {
        final user = referrals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.5),
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture == null
                    ? Icon(
                        IconlyBold.profile,
                        color: Theme.of(context).disabledColor,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: pBold14.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.createdAt != null
                          ? 'Bergabung: ${DateFormat('dd MMM yyyy').format(user.createdAt!)}'
                          : 'Bergabung: -',
                      style: pRegular12.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
