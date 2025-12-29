import SwiftUI

struct MainView: View {
    // 임시 데이터
    @State private var temperature: String = "24°"
    
    var body: some View {
        ZStack {
            // 1. 배경 (하늘색)
            Color(red: 0.4, green: 0.7, blue: 1.0) // 조금 더 예쁜 하늘색
                .ignoresSafeArea()
            
            // 2. 메인 콘텐츠
            VStack {
                // 상단 헤더
                HStack {
                    Button(action: {}) {
                        Image(systemName: "scope") // GPS 아이콘
                            .font(.title2)
                    }
                    Spacer()
                    Text("봉천동")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal") // 메뉴 아이콘
                            .font(.title2)
                    }
                }
                .padding()
                .foregroundColor(.white)
                
                Spacer()
                
                // ✨ 3. 캐릭터 (도형으로 직접 그리기)
                ZStack {
                    // [Layer 1] 다리/바지 (Pants)
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue) // 청바지 색
                            .frame(width: 35, height: 100)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(width: 35, height: 100)
                    }
                    .offset(y: 60) // 몸통 아래로 내리기
                    
                    // [Layer 2] 몸통/티셔츠 (Shirt)
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .frame(width: 140, height: 160)
                        .shadow(radius: 5) // 그림자 추가해서 입체감 주기
                    
                    // [Layer 3] 얼굴 (Face)
                    Circle()
                        .fill(Color(red: 1.0, green: 0.85, blue: 0.7)) // 살구색 피부
                        .frame(width: 80, height: 80)
                        .offset(y: -100) // 몸통 위로 올리기
                    
                    // [Layer 4] 온도 텍스트 (Text)
                    Text(temperature)
                        .font(.system(size: 50, weight: .black)) // 아주 굵은 폰트
                        .foregroundColor(.black)
                }
                .padding(.bottom, 50)
                
                Spacer()
                
                // 4. 하단 날씨 정보창 (카드 형태)
                VStack(alignment: .leading) {
                    Text("Hourly Forecast")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<10) { i in
                                VStack {
                                    Text("1\(i) PM")
                                        .font(.caption)
                                    Image(systemName: i % 2 == 0 ? "sun.max.fill" : "cloud.fill")
                                        .renderingMode(.original)
                                        .font(.title2)
                                    Text("2\(i)°")
                                        .font(.headline)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(15)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.bottom) // 아이폰 하단 홈 바 공간 확보
            }
        }
    }
}

#Preview {
    MainView()
}
