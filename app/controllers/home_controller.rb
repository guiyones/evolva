class HomeController < ApplicationController
  def index
    @focused_quest = Current.user.focused_quest
    @active_quests = Current.user.quests.active.recent if @focused_quest.nil?
  end
end
