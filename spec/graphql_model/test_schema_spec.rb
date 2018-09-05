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
      %{{
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
    }},
        variables: {},
        context: { current_user: nil }
        )
    pp result.to_h
    expect(result.to_h['errors']).to be_nil
  end
end
