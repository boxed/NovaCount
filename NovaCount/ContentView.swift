import SwiftUI

// Bigger star for finishing harder levels?


func answerToString(_ i: Int?) -> String {
    if let i = i {
        return String(i)
    }
    return ""
}


let onIPad = UIDevice.current.userInterfaceIdiom == .pad
let size: CGFloat = onIPad ? 3 : 1


func additionProblems(level: Int) -> [(Int, Int)] {
    let start = (level - 1) * 5
    let end = start + 4
    return (max(start, 1)...end).flatMap { x in
        (1...Int(ceil(Double(x)/2.0))).enumerated().map { i, y in
            let (a, b) = (x - i, y)
            // Randomize if the bigger number if to the left or to the right
            return Bool.random() ? (a, b) : (b, a)
        }
    }.shuffled()
}

let numberOfProblemsLimit = 10

let startProblems = additionProblems(level: 1).prefix(numberOfProblemsLimit)

enum Answer {
    case unanswered
    case correct
    case incorrect
}

func colorFromAnswer(_ answer: Answer) -> Color {
    switch answer {
    case .unanswered: return Color.gray
    case .correct: return Color.green
    case .incorrect: return Color.red
    }
}


struct ContentView: View {
    var numbers = -1000...1000
    @State var answers: [Answer] = (0..<(startProblems.count)).map { _ in Answer.unanswered }
    @State var level = 1;
    @State var problems: ArraySlice<(Int, Int)> = startProblems
    @State var currentProblem = 0
    @State var score = ""
    
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
    
    var left: Int {
        get {
            let (left, _) = problems[currentProblem]
            return left
        }
    }

    var right: Int {
        get {
            let (_, right) = problems[currentProblem]
            return right
        }
    }

    func newRound() {
        wrongAnswers = 0
        problems = additionProblems(level: level).prefix(numberOfProblemsLimit)
        answers = (0..<(problems.count)).map { _ in Answer.unanswered }
        currentProblem = 0
    }
    
    func nextProblem() {
        if currentProblem == problems.count - 1 {
            if answers.allSatisfy({answer in answer == .correct}) {
                score += "⭐️"
            }
            else if answers.allSatisfy({answer in answer == .incorrect}) {
                score += "🙁"
            }
            else {
                score += "✭"
            }
            newRound()
        }
        else {
            currentProblem += 1
        }
        wrongAnswers = 0
    }
    
    var points: some View {
        HStack {
            ForEach(answers, id: \.self) { answer in
                Text("●").foregroundColor(colorFromAnswer(answer))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30*size, maxHeight: 30*size, alignment: .center)
    }
    
    var stars: some View {
        Text(score).font(.system(size: 50))
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40*size, maxHeight: 40*size, alignment: .center)
    }
    
    var levelIndicatorAndSwitcher: some View {
        HStack {
            Button(action: {
                if level > 1 {
                    level -= 1
                }
                newRound()
            }) {
                Text("Lättare").padding()
            }.background(RoundedRectangle(cornerRadius: 4.0).stroke(Color.purple))
            
            Spacer()
            
            Text("Nivå \(level)").font(.system(size: 30))

            Spacer()
            
            Button(action: {
                level += 1
                newRound()
            }) {
                Text("Svårare").padding()
            }.background(RoundedRectangle(cornerRadius: 4.0).stroke(Color.purple))
        }.padding()
    }
    
    var problemAndAnswer: some View {
        if !problems.isEmpty {
            return Text("\(left) + \(right) = \(answerToString(answer))").font(.system(size: 60))
        }
        else {
            return Text("")
        }
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
                    answers[currentProblem] = .correct
                    nextProblem()
                }
                else {
                    if wrongAnswers > 0 {
                        answers[currentProblem] = .incorrect
                        nextProblem()
                    }
                    else {
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
            levelIndicatorAndSwitcher
            stars
            points
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
            .previewLayout(.sizeThatFits)
            .previewDevice("iPad (7th generation)")
    }
}
