# frozen_string_literal: true

describe do
  it 'test gql 1' do
    result = GuardianSchema.execute(
      %{{
          village(id: 45649) {
            status
            next_event
            reports {
              dot
              ocurrence
              pillage {
                wood
                stone
                iron
              }
              resources {
                wood
                stone
                iron
              }
            }
          }
        }},
      variables: {},
      context: { current_user: nil }
    )
    pp result.to_h
    expect(result.to_h['errors']).to be_nil
  end

  it 'test gql 2' do
    result = GuardianSchema.execute(
      %({
      task_abstracts {
        name
        last_execution
        next_execution
        job {
          run_at
          last_error
          attempts
          failed_at
        }
      }
    }),
      variables: {},
      context: { current_user: nil }
    )
    pp result.to_h
    expect(result.to_h['errors']).to be_nil
  end

  it 'test_schema' do
    result = GuardianSchema.execute(
      %(query IntrospectionQuery {
        __schema {
          queryType { name }
          mutationType { name }
          subscriptionType { name }
          types {
            ...FullType
          }
          directives {
            name
            description
            locations
            args {
              ...InputValue
            }
          }
        }
      }
    
      fragment FullType on __Type {
        kind
        name
        description
        fields(includeDeprecated: true) {
          name
          description
          args {
            ...InputValue
          }
          type {
            ...TypeRef
          }
          isDeprecated
          deprecationReason
        }
        inputFields {
          ...InputValue
        }
        interfaces {
          ...TypeRef
        }
        enumValues(includeDeprecated: true) {
          name
          description
          isDeprecated
          deprecationReason
        }
        possibleTypes {
          ...TypeRef
        }
      }
    
      fragment InputValue on __InputValue {
        name
        description
        type { ...TypeRef }
        defaultValue
      }
    
      fragment TypeRef on __Type {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                    }
                  }
                }
              }
            }
          }
        }
      }),
      variables: {},
      context: { current_user: nil }
    )
    expect(result.to_h['errors']).to be_nil
  end
end
