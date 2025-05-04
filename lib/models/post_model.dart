class Post {
  final String username;
  final String location;
  final String imageUrl;
  final String profileId;
  final String profilePic;
  final int likeCount;
  final int commentCount;

  Post({
    required this.username,
    required this.location,
    required this.imageUrl,
    required this.profileId,
    required this.profilePic,
    required this.likeCount,
    required this.commentCount,
  });

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      username: data['userName'] ?? 'User',
      location: data['location'] ?? '',
      imageUrl:
          data['imageUrl'] ??
          'https://img.freepik.com/premium-vector/no-photos-icon-vector-image-can-be-used-spa_120816-264914.jpg?ga=GA1.1.620892737.1745985582&semt=ais_hybrid&w=740',
      profileId: data['userId'] ?? '',
      profilePic:
          data['userProfilePic'] ??
          'https://img.freepik.com/premium-vector/character-avatar-isolated_729149-194801.jpg?ga=GA1.1.620892737.1745985582&semt=ais_hybrid&w=740',
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
    );
  }
}
