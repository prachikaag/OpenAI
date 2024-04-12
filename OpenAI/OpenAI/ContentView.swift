//
//  ContentView.swift
//  OpenAI
//
//  Created by PRACHIKA AGARWAL on 11/04/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var chatMessages: [ChatMessage] = []
    @State var messageText: String = ""
    let openAiService = OpenAiService()
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack {
                    ForEach(chatMessages, id: \.id){message in
                        messageView(message: message)
                    }
                }
            }
            HStack{
                TextField("What's on your mind today?", text: $messageText)
                    .padding()
                    .foregroundColor(.gray)
                    .background(.purple.opacity(0.1))
                Button{
                    sendMessage()
                } label: {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(.purple)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    func messageView(message: ChatMessage) -> some View{
        HStack{
            if message.sender == .me { Spacer() }
            Text(message.content)
                .foregroundColor(message.sender == .me ? .blue : .purple)
                .padding()
                .background(message.sender == .me ? .blue.opacity(0.1) : .purple.opacity(0.1))
                .cornerRadius(16)
            if message.sender == .gpt {Spacer()}
        }
    }
    
    func sendMessage() {
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        openAiService.sendMessage(message: messageText)
            .sink { completion in
                // Handle error
            } receiveValue: { response in
                guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else { return }
                let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
                chatMessages.append(gptMessage)
            }
            .store(in: &cancellables)
        messageText = ""
    }

}

struct ContentView_Preview: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}

struct ChatMessage{
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
}

enum MessageSender{
    case me
    case gpt
}

extension ChatMessage{
    static let sampleMessages = [
        ChatMessage(id: UUID().uuidString, content: "String", dateCreated: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "String", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "String", dateCreated: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "String", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "String", dateCreated: Date(), sender: .gpt)
    ]
}
