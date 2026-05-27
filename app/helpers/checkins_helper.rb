module CheckinsHelper
  FEELING_LABELS = { "hard" => "Difícil", "ok" => "Ok", "easy" => "Fácil" }.freeze

  def feeling_label(value)
    FEELING_LABELS[value.to_s] || value
  end
end
