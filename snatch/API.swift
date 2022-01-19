// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class MatchesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Matches {
      allMatches {
        __typename
        teamSize
        opponentSize
        owner {
          __typename
          username
          firstName
          lastName
          age
          weight
          height
          userPicture
        }
      }
    }
    """

  public let operationName: String = "Matches"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("allMatches", type: .list(.object(AllMatch.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(allMatches: [AllMatch?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "allMatches": allMatches.flatMap { (value: [AllMatch?]) -> [ResultMap?] in value.map { (value: AllMatch?) -> ResultMap? in value.flatMap { (value: AllMatch) -> ResultMap in value.resultMap } } }])
    }

    public var allMatches: [AllMatch?]? {
      get {
        return (resultMap["allMatches"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [AllMatch?] in value.map { (value: ResultMap?) -> AllMatch? in value.flatMap { (value: ResultMap) -> AllMatch in AllMatch(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [AllMatch?]) -> [ResultMap?] in value.map { (value: AllMatch?) -> ResultMap? in value.flatMap { (value: AllMatch) -> ResultMap in value.resultMap } } }, forKey: "allMatches")
      }
    }

    public struct AllMatch: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MatchesList"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teamSize", type: .scalar(Int.self)),
          GraphQLField("opponentSize", type: .scalar(Int.self)),
          GraphQLField("owner", type: .nonNull(.object(Owner.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(teamSize: Int? = nil, opponentSize: Int? = nil, owner: Owner) {
        self.init(unsafeResultMap: ["__typename": "MatchesList", "teamSize": teamSize, "opponentSize": opponentSize, "owner": owner.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamSize: Int? {
        get {
          return resultMap["teamSize"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "teamSize")
        }
      }

      public var opponentSize: Int? {
        get {
          return resultMap["opponentSize"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "opponentSize")
        }
      }

      public var owner: Owner {
        get {
          return Owner(unsafeResultMap: resultMap["owner"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "owner")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["UsersList"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("username", type: .nonNull(.scalar(String.self))),
            GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
            GraphQLField("lastName", type: .nonNull(.scalar(String.self))),
            GraphQLField("age", type: .nonNull(.scalar(Int.self))),
            GraphQLField("weight", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.scalar(Double.self))),
            GraphQLField("userPicture", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(username: String, firstName: String, lastName: String, age: Int, weight: Int, height: Double, userPicture: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "UsersList", "username": username, "firstName": firstName, "lastName": lastName, "age": age, "weight": weight, "height": height, "userPicture": userPicture])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.
        public var username: String {
          get {
            return resultMap["username"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "username")
          }
        }

        public var firstName: String {
          get {
            return resultMap["firstName"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "firstName")
          }
        }

        public var lastName: String {
          get {
            return resultMap["lastName"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "lastName")
          }
        }

        public var age: Int {
          get {
            return resultMap["age"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "age")
          }
        }

        public var weight: Int {
          get {
            return resultMap["weight"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "weight")
          }
        }

        public var height: Double {
          get {
            return resultMap["height"]! as! Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "height")
          }
        }

        public var userPicture: String? {
          get {
            return resultMap["userPicture"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "userPicture")
          }
        }
      }
    }
  }
}
