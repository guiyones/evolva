tags = [
  { name: "Saúde", icon: "💪" },
  { name: "Alimentação", icon: "🥗" },
  { name: "Exercício", icon: "🏃" },
  { name: "Leitura", icon: "📚" },
  { name: "Estudo", icon: "🎓" },
  { name: "Produtividade", icon: "⚡" },
  { name: "Finanças", icon: "💰" },
  { name: "Sono", icon: "😴" },
  { name: "Meditação", icon: "🧘" },
  { name: "Criatividade", icon: "🎨" },
  { name: "Relacionamentos", icon: "❤️" },
  { name: "Foco", icon: "🎯" }
]

tags.each do |tag|
  Tag.find_or_create_by!(name: tag[:name]) do |t|
    t.icon = tag[:icon]
  end
end

puts "#{Tag.count} tags criadas."
