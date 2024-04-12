//
//  OpenAiService.swift
//  OpenAI
//
//  Created by PRACHIKA AGARWAL on 11/04/24.
//

import Foundation
import Alamofire
import Combine

class OpenAiService {
    let baseUrl = "https://api.openai.com/v1/"

    func sendMessage(message: String) -> AnyPublisher<OpenAICompletionResponse,Error> {
        let body = OpenAICompletionRequest(model: "gpt-3.5-turbo-instruct", prompt: message, temperature: 0.8, max_tokens: 256)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAPIKey)"
        ]
        return Future{ [weak self] promise in
            guard let self = self else { return }
            AF.request(self.baseUrl + "completions", method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: headers).responseDecodable(of: OpenAICompletionResponse.self){response in
                switch response.result{
                case .success(let result):
                    promise(.success(result))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

struct OpenAICompletionRequest: Encodable {
    let model: String
    let prompt: String
    let temperature: Float?
    let max_tokens: Int?
}

struct OpenAICompletionResponse: Decodable{
    let id: String
    let choices: [OpenAICompletionOptions]
}

struct OpenAICompletionOptions: Decodable{
    let text: String
}
