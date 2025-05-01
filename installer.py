from rich.console import Console
from rich.prompt import Prompt
from rich.panel import Panel
from modules import core_tools, ad_tools, cloud_tools, c2s, kde_setup

console = Console()

def main_menu():
    console.print(Panel.fit("[bold cyan]Security Raccoon Installer[/bold cyan] 🦝", expand=False))
    console.print("Select a category to install:
")
    console.print("[1] Core Pentest Tools")
    console.print("[2] Active Directory Tools")
    console.print("[3] Cloud Tools")
    console.print("[4] C2 Frameworks (Empire, Sliver)")
    console.print("[5] Desktop Environment & Customization")
    console.print("[0] Exit
")

    choice = Prompt.ask("[bold green]Enter your choice[/bold green]", choices=["1", "2", "3", "4", "5", "0"], default="0")

    if choice == "1":
        core_tools.install()
    elif choice == "2":
        ad_tools.install()
    elif choice == "3":
        cloud_tools.install()
    elif choice == "4":
        c2s.install()
    elif choice == "5":
        kde_setup.install()
    elif choice == "0":
        console.print("[bold red]Exiting installer. Goodbye![/bold red]")
        exit(0)

if __name__ == "__main__":
    while True:
        main_menu()
