alias ElixirChat.Repo
alias ElixirChat.Chat
alias ElixirChat.Accounts
alias ElixirChat.Chat.Room

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirChat.Repo.insert!(%ElixirChat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Faker.start(:pt_BR)

Repo.insert!(%Room{name: "Funny group", description: "A very funny chat group"})
Repo.insert!(%Room{name: "Serious group", description: "A very serious chat group"})

for _n <- 1..10 do
  name = Faker.Person.first_name()
  email = "#{String.downcase(name)}@streamchat.io"
  Accounts.register_user(%{email: email, password: "passw0rd!passw0rd!"})
end

for _n <- 1..100 do
  Chat.create_message(%{
    content: Faker.Lorem.sentence(),
    room_id: Enum.random([1,2]),
    user_id: Enum.random([1,2,3,4,5,6,7,8,9,10])
  })
end
