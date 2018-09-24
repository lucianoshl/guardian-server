# frozen_string_literal: true

describe String do
  it 'string_bug_01' do
    'Set 10, 2018  10:30:32'.to_datetime
  end

  it 'string_bug_02' do
    'set 24, 2018  15:17:28:571'.to_datetime
  end

end
