import 'package:flutter/material.dart';

class HTPMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBarWidget(),
            Expanded(child: HTPContent()),
          ],
        ),
      ),
    );
  }
}

class AppBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          Row(
            children: [
              IconButton(
                icon: Image.asset('assets/images/home_icon.png'),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('assets/images/mypage_icon.png'),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('assets/images/logout_icon.png'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HTPContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HTP 검사',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                'assets/images/rabbit_icon.png',
                width: 48,
                height: 48,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'HTP 검사란?\n\n벅(Buck, 1948)이 고안한 투사적 그림검사로서 집, 나무, 사람을 각각 그리게 하여 '
                      '내담자의 성격, 행동 양식 및 대인관계를 파악할 수 있습니다. 피험자의 성격적 특징뿐만 아니라 지적 수준을 평가하고 '
                      '또한 정신장애 및 신경증의 부분적 양상을 파악하는데 널리 사용되기도 합니다.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DrawingCard(imagePath: 'assets/images/drawing1.png'),
              DrawingCard(imagePath: 'assets/images/drawing2.png'),
              DrawingCard(imagePath: 'assets/images/drawing3.png'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('메인 페이지로'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('다음'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawingCard extends StatelessWidget {
  final String imagePath;

  DrawingCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          imagePath,
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
