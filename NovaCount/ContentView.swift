import SwiftUI


func answerToString(_ i: Int?) -> String {
    if let i = i {
        return String(i)
    }
    return ""
}

var initialStarDifficulty = 1

let onIPad = UIDevice.current.userInterfaceIdiom == .pad
let size: CGFloat = onIPad ? 3 : 1

struct ContentView: View {
    var numbers = -1000...1000
    @State var answers: [Bool] = []
    @State var difficulty = initialStarDifficulty * 10
    
    
    var difficultyStarRating: Int {
        get {
            return difficulty / 10
        }
    }
    
    @State var left: Int = Int.random(in: 1...initialStarDifficulty)
    @State var right: Int = Int.random(in: 1...initialStarDifficulty)
    @State var answer: Int? = nil
    @State var wrongAnswers = 0
    @State var scrollViewProxy: ScrollViewProxy? = nil
    
    init() {
           //Use this if NavigationBarTitle is with Large Font
           UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]

           //Use this if NavigationBarTitle is with displayMode = .inline
           UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
        newRound()
    }

    func newRound() {
        if difficulty < 10 {
            difficulty = 10
        }
        let bottom = difficultyStarRating
        let top = difficultyStarRating + 3
        left = Int.random(in: bottom...top)
        right = Int.random(in: bottom...top)
        wrongAnswers = 0
    }
    
    var points: some View {
        HStack {
            ForEach(answers.indices, id: \.self) { i in
                Text("●").foregroundColor(answers[i] ? Color.green: Color.red)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30*size, maxHeight: 30*size, alignment: .center)
    }
    
    var levelIndicatorWithStars: some View {
        HStack {
            ForEach(1...difficultyStarRating, id: \.self) { number in
                Text("⭐️").font(.system(size: 20*size))
            }
        }
    }
    
    var problemAndAnswer: some View {
        Text("\(left) + \(right) = \(answerToString(answer))").font(.system(size: 60))
    }
    
    var numberLine: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                LazyHStack(spacing: 0) {
                    let buttonWidth = 30*size
                    ForEach(self.numbers, id: \.self) { number in
                        Button(action: {self.answer = number}) {
                            VStack {
                                Path { path in
                                    path.move(to: CGPoint(x: buttonWidth/2, y: 0))
                                    path.addLine(to: CGPoint(x: buttonWidth/2, y: 10))
                                    path.move(to: CGPoint(x: 0, y: 0))
                                    path.addLine(to: CGPoint(x: buttonWidth, y: 0))
                                }
                                .stroke()
                                .frame(width: buttonWidth, height: 10)

                                Text("\(number)")
                                .font(.system(size: 10*size))
                                .frame(width: buttonWidth, height: 20*size)
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                }
                .onAppear {
                    scrollView.scrollTo(5, anchor: .center)
                    scrollViewProxy = scrollView
                }
            }
        }
        .padding(.horizontal)
    }
    
    var answerBody: some View {
        Button(action: {
            if let answer = answer {
                if (left + right == answer) {
                    answers.append(true)
                    difficulty += 2
                    newRound()
                }
                else {
                    if wrongAnswers > 0 {
                        answers.append(false)
                        difficulty -= 5
                        newRound()
                    }
                    else {
                        difficulty -= 1
                        wrongAnswers += 1
                    }
                }
            }
            answer = nil
        }) {
            Text("Svara").padding()
        }
        .background(RoundedRectangle(cornerRadius: 4.0).stroke(Color.purple))
    }
    
    var jumpOnNumberLine: some View {
        HStack {
            ForEach([-500, -100, 0, 100, 500], id: \.self) { number in
                Button(action: {
                    var targetJump = number
                    if targetJump == 0 {
                        targetJump = 5
                    }
                    if let scrollViewProxy = scrollViewProxy {
                        scrollViewProxy.scrollTo(targetJump, anchor: .center)
                    }
                }) {
                    Text("\(number)".replacingOccurrences(of: ",", with: "")).padding()
                }
            }
        }
        .padding(10)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            points
            levelIndicatorWithStars
            problemAndAnswer
            numberLine
            answerBody
            Spacer()
            jumpOnNumberLine
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Rectangle().fill(Color.black)).foregroundColor(Color.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
