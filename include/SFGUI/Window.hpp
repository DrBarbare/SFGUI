#pragma once

#include <SFGUI/Config.hpp>
#include <SFGUI/Bin.hpp>
#include <memory>
#include <SFML/Graphics/Drawable.hpp>
#include <SFML/System/String.hpp>
#include <cstdint>

namespace sfg {

/** Window.
 */
class SFGUI_API Window : public Bin {
	public:
		typedef std::shared_ptr<Window> Ptr; //!< Shared pointer.
		typedef std::shared_ptr<const Window> PtrConst; //!< Shared pointer.

		enum Style : std::uint8_t {
			NO_STYLE = 0, //!< Transparent window.
			TITLEBAR = 1 << 0, //!< Titlebar.
			BACKGROUND = 1 << 1, //!< Background.
			RESIZE = 1 << 2, //!< Resizable.
			SHADOW = 1 << 3, //!< Display Shadow.
			TOPLEVEL = TITLEBAR | BACKGROUND | RESIZE //!< Toplevel window.
		};

		/** Create window.
		 * @param style Style the Window should have. Defaults to TopLevel.
		 */
		static Ptr Create( std::uint8_t style = Style::TOPLEVEL );

		virtual const std::string& GetName() const override;

		/** Set window title.
		 * @param title Title.
		 */
		void SetTitle( const sf::String& title );

		/** Get window title.
		 * @return Title.
		 */
		const sf::String& GetTitle() const;

		/** Get client area.
		 * @return Rect.
		 */
		sf::FloatRect GetClientRect() const;

		/** Set window style.
		 * Can be a combination of Window::Style values.
		 * @param style New style.
		 */
		void SetStyle( std::uint8_t style );

		/** Get window style.
		 * @return Window style.
		 */
		std::uint8_t GetStyle() const;

		/** Check if the window has a specific style.
		 * @param style Style to check.
		 * @return true when window has desired style.
		 */
		bool HasStyle( Style style ) const;

	protected:
		/** Constructor.
		 * @param style Window style.
		 */
		Window( std::uint8_t style );

		virtual std::unique_ptr<RenderQueue> InvalidateImpl() const override;

		virtual sf::Vector2f CalculateRequisition() override;

	private:
		void HandleSizeChange();
		void HandleMouseButtonEvent( sf::Mouse::Button button, bool press, int x, int y );
		void HandleMouseMoveEvent( int x, int y );
		void HandleAdd( const Widget::Ptr& child );

		sf::Vector2f m_drag_offset;

		sf::String m_title;
		std::uint8_t m_style;

		bool m_dragging;
		bool m_resizing;
};

}
