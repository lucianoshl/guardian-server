# frozen_string_literal: true

class Quest::MentorSystem < Quest::Abstract
  def start
    binding.pry
    Client::Mobile.logged.get('/game.php?screen=mentor')
  end
end
