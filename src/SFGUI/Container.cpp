#include <SFGUI/Container.hpp>

namespace sfg {

void Container::Add( const Widget::Ptr& widget ) {
	if( IsChild( widget ) ) {
		return;
	}

	m_children.push_back( widget );
	HandleAdd( widget );

	// Check if HandleAdd still wants the little boy.
	if( IsChild( widget ) ) {
		widget->SetParent( shared_from_this() );
		RequestResize();
	}
}

void Container::Remove( const Widget::Ptr& widget ) {
	WidgetsList::iterator iter( std::find( m_children.begin(), m_children.end(), widget ) );

	if( iter != m_children.end() ) {
		m_children.erase( iter );
		widget->SetParent( Widget::Ptr() );
		HandleRemove( widget );

		RequestResize();
	}
}

void Container::RemoveAll() {
	while( !m_children.empty() ) {
		auto widget = m_children.back();

		m_children.pop_back();
		widget->SetParent( Widget::Ptr() );
		HandleRemove( widget );
	}

	RequestResize();
}

bool Container::IsChild( const Widget::Ptr& widget ) const {
	for( const auto& child : m_children ) {
		if( child == widget ) {
			return true;
		}
	}

	return false;
}

const Container::WidgetsList& Container::GetChildren() const {
	return m_children;
}

void Container::Refresh() {
	for( const auto& child : m_children ) {
		child->Refresh();
	}

	Widget::Refresh();
}

void Container::HandleEvent( const sf::Event& event ) {
	// Ignore event when widget is not visible.
	if( !IsGloballyVisible() ) {
		return;
	}

	// Create a copy of the event and transform mouse coordinates to local
	// coordinates if event is a mouse event.
	sf::Event local_event( event );

	if( local_event.type == sf::Event::MouseMoved ) {
		local_event.mouseMove.x -= static_cast<int>( GetAllocation().left );
		local_event.mouseMove.y -= static_cast<int>( GetAllocation().top );
	}

	if(
		local_event.type == sf::Event::MouseButtonPressed ||
		local_event.type == sf::Event::MouseButtonReleased
	) {
		local_event.mouseButton.x -= static_cast<int>( GetAllocation().left );
		local_event.mouseButton.y -= static_cast<int>( GetAllocation().top );
	}

	// Pass event to children.
	for( const auto& child : m_children ) {
		child->HandleEvent( local_event );
	}

	// Process event for own widget.
	Widget::HandleEvent( event );
}

void Container::HandleAdd( const Widget::Ptr& child ) {
	child->SetViewport( GetViewport() );
}

void Container::HandleRemove( const Widget::Ptr& /*child*/ ) {
}

void Container::HandleChildInvalidate( const Widget::PtrConst& child ) const {
	auto parent = GetParent();

	if( parent ) {
		parent->HandleChildInvalidate( child );
	}
}

void Container::HandleAbsolutePositionChange() {
	// Update children's drawable positions.
	for( const auto& child : m_children ) {
		child->HandleAbsolutePositionChange();
	}

	// Update own drawable position.
	Widget::HandleAbsolutePositionChange();
}

void Container::HandleGlobalVisibilityChange() {
	Widget::HandleGlobalVisibilityChange();

	for( const auto& child : m_children ) {
		child->HandleGlobalVisibilityChange();
	}
}

void Container::HandleUpdate( float seconds ) {
	Widget::HandleUpdate( seconds );

	for( const auto& child : m_children ) {
		child->Update( seconds );
	}
}

void Container::HandleSetHierarchyLevel() {
	Widget::HandleSetHierarchyLevel();

	for( const auto& child : m_children ) {
		child->SetHierarchyLevel( GetHierarchyLevel() + 1 );
	}
}

void Container::HandleViewportUpdate() {
	for( const auto& child : m_children ) {
		child->SetViewport( GetViewport() );
	}

	Widget::HandleViewportUpdate();
}

}
