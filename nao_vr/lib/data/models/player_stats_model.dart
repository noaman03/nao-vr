class PlayerStatsModel {
  final String userId;
  final int kills;
  final int deaths;
  final int assists;
  final int wins;
  final int losses;
  final int gamesPlayed;
  final double kdaRatio;
  final double winRate;
  final int headshots;
  final double accuracy;
  final String rank;
  final int rankPoints;

  PlayerStatsModel({
    required this.userId,
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.wins = 0,
    this.losses = 0,
    this.gamesPlayed = 0,
    this.kdaRatio = 0.0,
    this.winRate = 0.0,
    this.headshots = 0,
    this.accuracy = 0.0,
    this.rank = 'Unranked',
    this.rankPoints = 0,
  });

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      userId: json['userId'] as String,
      kills: json['kills'] as int? ?? 0,
      deaths: json['deaths'] as int? ?? 0,
      assists: json['assists'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      kdaRatio: (json['kdaRatio'] as num?)?.toDouble() ?? 0.0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      headshots: json['headshots'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as String? ?? 'Unranked',
      rankPoints: json['rankPoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'kills': kills,
      'deaths': deaths,
      'assists': assists,
      'wins': wins,
      'losses': losses,
      'gamesPlayed': gamesPlayed,
      'kdaRatio': kdaRatio,
      'winRate': winRate,
      'headshots': headshots,
      'accuracy': accuracy,
      'rank': rank,
      'rankPoints': rankPoints,
    };
  }

  double get kd => deaths > 0 ? kills / deaths : kills.toDouble();
}
